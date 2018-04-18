var express = require('express');
var router = express.Router();

const db = require('../routes/db'); // configures connection to the DB.
const pgp = db.$config.pgp;
const apnModule = require('../routes/apn'); // Configures connection to Apple Push Notification service using our Apple Developer Account.
const apn = apnModule.apn;
const apnProvider = apnModule.apnProvider;

function sendPushNotification(message, deviceToken)
{
  let notification = new apn.Notification();
  notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600; // will expire in 24 hours from now
  notification.badge = 2;
  notification.sound = "ping.aiff";
  notification.alert = message;
  notification.payload = {'messageFrom': 'CarPool'};

  // Replace this with your app bundle ID:
  notification.topic = "com.CSC4996.CarpoolApp";

  apnProvider.send(notification, deviceToken).then( result => {
    // Sends a push notifications to the other party that their ride has been cancelled.
  // Show the result of the send operation:
     console.log(result);
  });
}

function createScheduledRoutes(day, dayNum, matchID)
{
    db.query(`select d::date from generate_series(current_date + cast(abs(extract(dow from current_date) - 7) + ${dayNum} as int), current_date + cast(abs(extract(dow from current_date) - 7) + 6 as int) + interval '1 month', '1 week'::interval) d`)
      .then(function(result) {
        var resultDates = result.length;
        for (var y = 0; y < resultDates; y++)
        {
          db.query(`INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\", \"routeType\") values ('${day}', ${matchID}, 'Scheduled', $1, 'toDestination')`, [result[y].d]);
          db.query(`INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\", \"routeType\") values ('${day}', ${matchID}, 'Scheduled', $1, 'fromDestination')`, [result[y].d]);
        }
      })
      .catch(function (err) {
        console.log(err);
      });

}

// This POST request handles the rider/driver approval process during matching.
router.post('/approval', function(req, res, next) {
 var requestInfo = req.body.requestInfo
 var requestJSON = JSON.parse(requestInfo);
 var userID = requestJSON['userID'];
 var matchID = requestJSON['matchID'];


// This is the case to handle a rider requesting a driver.
if (requestJSON['requestType'] == 'riderRequest') // If the rider has requested a driver
{

  db.query(`UPDATE carpool.\"Matches\" SET \"Status\" = 'driverRequested' where \"matchID\" = ${matchID}`) // update match to driver requested.
   .then(function () {
     db.one(`SELECT \"driverID\" from carpool.\"Matches\" where \"matchID\" = ${matchID}`)
     .then(function(data) {
        db.any(`INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ('${data.driverID}', 'You have a new ride request!', 'now', 'false')`);
        db.one(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${data.driverID}'`)
        .then(function(result) {
          sendPushNotification("You have a new ride request!", result.deviceToken);
        })
     })
     res.status(200)
       .json({
         status: 'Success',
         message: 'Match Updated.'
       });
   })
   .catch(function (err) {
     res.send(err);
   });

 }


// Handles the case of a drive approving a rider's request.
 else {
   db.query(`UPDATE carpool.\"Matches\" SET \"Status\" = 'Matched' where \"matchID\" = ${matchID}`) // If the request was a driver approving a request, switch the request status to matched.
   .then(function () {
     db.one(`SELECT \"riderID\" from carpool.\"Matches\" where \"matchID\" = ${matchID}`)
     .then(function(data) {
        db.any(`INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ('${data.riderID}', 'Your rider request has been approved!', 'now', 'false')`);
        db.one(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${data.riderID}'`)
        .then(function(result) {
          sendPushNotification("Your ride request has been approved!", result.deviceToken);
          db.query(`UPDATE carpool.\"Routes\" SET \"Matched\" = 'true' where \"routeID\" = ${requestJSON['driverRouteID']}`) // Update the matched column in driver route.
          .then(function() {
                db.query(`UPDATE carpool.\"Routes\" SET \"Matched\" = 'true' where \"routeID\" = ${requestJSON['riderRouteID']}`) // Update matched column in rider route.
                .then(function() {
                  var numOfDays =  requestJSON['Days'].length;
                  console.log("Number of Days", numOfDays);
                  // Each individual day will have its own row in the DB, this will allow us to manage cancellations, etc.
                  for (var i = 0; i < numOfDays; i++) {
                      if (requestJSON['Days'][i] == 'monday')
                      {
                        createScheduledRoutes('monday', 1, matchID);
                      }
                      else if (requestJSON['Days'][i] == 'tuesday')
                      {
                        createScheduledRoutes('tuesday', 2, matchID);
                      }


                      else if (requestJSON['Days'][i] == 'wednesday')
                      {
                          createScheduledRoutes('wednesday', 3, matchID);
                      }

                      else if (requestJSON['Days'][i] == 'thursday')
                      {
                          createScheduledRoutes('thursday', 4, matchID);
                      }

                      else if (requestJSON['Days'][i] == 'friday')
                      {
                          createScheduledRoutes('friday', 5, matchID);
                      }

                      else if (requestJSON['Days'][i] == 'saturday')
                      {
                          createScheduledRoutes('saturday', 6, matchID);
                      }

                      else if (requestJSON['Days'][i] == 'sunday')
                      {
                          createScheduledRoutes('sunday', 0, matchID);
                      }

                  }
                }) // Update the matched column in rider route.
                .catch(function (err) {
                  console.log(err);
                });
        })


     })
   })

     res.status(200)
       .json({
         status: 'Success',
         message: 'Match Stored.'
       });
 })


 }
});


// Get all match information associated with the specific user.
router.get('/', function(req, res, next) {
var userID = req.query.userID;
 // Select all drivers the rider has matched with so they can request one.
db.query(`select distinct on (\"matchID\") * from (select \"firstName\" as \"riderFirstName\", \"lastName\" as \"riderLastName\", \"Biography\" as \"riderBiography\", \"userID\" from carpool.\"Users\")g JOIN ((select \"startPointLat\" as \"riderStartPointLat\", \"startPointLong\" as \"riderStartPointLong\", \"endPointLat\" as \"riderEndPointLat\", \"endPointLong\" as \"riderEndPointLong\", \"riderID\" as \"riderRouteUserID\", \"Days\" as \"riderDays\", \"arrivalTime1\" as \"riderArrival1\",\"arrivalTime2\" as \"riderArrival2\", \"departureTime1\" as \"riderDeparture1\",\"departureTime2\" as \"riderDeparture2\", \"Name\" as \"riderRouteName\", \"routeID\", \"startAddress\" as \"riderStartAddress\", \"endAddress\" as \"riderEndAddress\" from carpool.\"Routes\")e JOIN ((select \"startPointLat\" as \"driverStartPointLat\", \"startPointLong\" as \"driverStartPointLong\", \"endPointLat\" as \"driverEndPointLat\", \"endPointLong\" as \"driverEndPointLong\",\"driverID\" as \"driverRouteUserID\",\"Days\" as \"driverDays\",\"arrivalTime1\" as \"driverArrival1\",\"arrivalTime2\" as \"driverArrival2\",\"departureTime1\" as \"driverDeparture1\",\"departureTime2\" as \"driverDeparture2\", \"Name\" as \"driverRouteName\",\"routeID\", \"startAddress\" as \"driverStartAddress\", \"endAddress\" as \"driverEndAddress\" from carpool.\"Routes\") d  JOIN ((select * from carpool.\"Matches\" where (\"riderID\" = '${userID}' AND \"Status\" = 'Awaiting rider request.') OR (\"driverID\" = '${userID}' AND \"Status\" = 'driverRequested') ) a  JOIN (select \"firstName\" as \"driverFirstName\", \"lastName\" as \"driverLastName\",\"Biography\" as \"driverBiography\",\"userID\" from carpool.\"Users\")b  ON a.\"driverID\" = b.\"userID\")c  ON c.\"driverRouteID\" = d.\"routeID\")f ON e.\"riderRouteUserID\" = f.\"riderID\")h ON g.\"userID\" = h.\"riderID\"`)
.then(function(data) {
  res.send(data);
  });
});






module.exports = router;
