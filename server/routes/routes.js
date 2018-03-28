var express = require('express');
var router = express.Router();

const db = require('../routes/db'); // configures our connection to the DB.
const pgp = db.$config.pgp;
const apnModule = require('../routes/apn'); // Allows us to connect to Apple Push Notification Service.
const apn = apnModule.apn;
const apnProvider = apnModule.apnProvider;

var distance = require('google-distance');  // Google Distance Matrix API module.

function convertTo24Hour(time) { // Converts time from 12-hour format to 24-hour format.
    time = time.toUpperCase();
    var hours = parseInt(time.substr(0, 2));
    if(time.indexOf('AM') != -1 && hours == 12) {
        time = time.replace('12', '0');
    }
    if(time.indexOf('PM')  != -1 && hours < 12) {
        time = time.replace(hours, (hours + 12));
    }
    var time = time.replace(/( AM| PM)/, '');
    return (time + ':00');
}



// This GET request returns all routes a user has previously entered.
router.get('/saved', function(req, res, next) {
var userID = req.query.userID;
db.query(`select * from carpool.\"Routes\" where \"driverID\" = '${userID}' OR \"riderID\" = '${userID}'`)
.then(function(data) {
 res.send(data);
  });
});



//This GET request returns all routes a user is currently scheduled for.
router.get('/scheduled', function(req, res, next) {
var userID = req.query.userID;
db.query(`select \"rideCost\", \"driverFirstName\", \"driverStartAddress\", \"driverEndAddress\", \"driverStartPointLat\", \"driverStartPointLong\", \"driverEndPointLat\", \"driverEndPointLong\", \"riderFirstName\", \"riderStartAddress\", \"riderEndAddress\", \"riderStartPointLat\", \"riderStartPointLong\", \"riderEndPointLat\", \"riderEndPointLong\", \"matchID\", \"Day\", \"Date\", \"driverRouteID\",  \"riderRouteID\", \"riderID\", \"driverID\", \"riderPickupTime\", \"riderDropOffTime\", \"driverLeaveTime\", \"riderPickupTime2\", \"driverRouteName\", \"riderRouteName\" from (select \"firstName\" as \"riderFirstName\", \"userID\" from carpool.\"Users\") h JOIN ((select \"firstName\" as \"driverFirstName\", \"userID\" from carpool.\"Users\") h JOIN ((select \"startPointLat\" as \"driverStartPointLat\",  \"startPointLong\" as \"driverStartPointLong\", \"endPointLat\" as \"driverEndPointLat\",  \"endPointLong\" as \"driverEndPointLong\", \"routeID\", \"Name\" as \"driverRouteName\", \"startAddress\" as \"driverStartAddress\", \"endAddress\" as \"driverEndAddress\" from carpool.\"Routes\")e JOIN ((select \"startPointLat\" as \"riderStartPointLat\", \"startPointLong\" as \"riderStartPointLong\", \"endPointLat\" as \"riderEndPointLat\",  \"endPointLong\" as \"riderEndPointLong\", \"routeID\", \"Name\" as \"riderRouteName\", \"startAddress\" as \"riderStartAddress\", \"endAddress\" as \"riderEndAddress\" from carpool.\"Routes\") c JOIN ((select \"Day\", \"Date\", \"Status\", \"matchID\" as \"scheduledRideMatchID\" from carpool.\"scheduledRoutes\" where \"Date\" >= 'now' and \"Status\" != 'CANCELLED') a JOIN (select * from carpool.\"Matches\" where (\"riderID\" = '${userID}' OR \"driverID\" = '${userID}') AND \"Status\" = 'Matched') b ON a.\"scheduledRideMatchID\" = b.\"matchID\")d ON d.\"riderRouteID\" = c.\"routeID\")f ON f.\"driverRouteID\" = e.\"routeID\")g ON g.\"driverID\" = h.\"userID\") j ON j.\"riderID\" = h.\"userID\" ORDER BY \"Date\" LIMIT 20`)
.then(function(data) {
 res.send(data);
  });
});



// This POST request allows a user to cancel an individual ride or an entire ride series.
router.post('/cancel', function(req, res, next) {
  var cancelInfo = req.body.cancelInfo;
  var cancelJSON = JSON.parse(cancelInfo);
  var otherID = cancelJSON['otherID'];
  var matchID = cancelJSON['matchID'];

  if (cancelJSON['cancelType'] == "Individual") // Case for cancelling an individual ride.
  {
  var date = cancelJSON['Date']; // Date of the cancelled ride.

  db.query(`UPDATE carpool.\"scheduledRoutes\" SET \"Status\" = 'CANCELLED' where \"Date\" = '${date}' AND \"matchID\" = ${matchID}`)
  .then( function (){
    console.log(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${otherID}'`);
    db.one(`SELECT \"deviceToken\", \"firstName\" from carpool.\"Users\" where \"userID\" = '${otherID}'`)
    .then(function(result) {
      let notification = new apn.Notification();
       notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600; // will expire in 24 hours from now
      notification.badge = 2;
      notification.sound = "ping.aiff";
      notification.alert = `Your ride with ${result.firstName} on ${date} has been cancelled.`;
      notification.payload = {'messageFrom': 'Notifications are working!'};

       // Replace this with your app bundle ID:
       notification.topic = "com.CSC4996.CarpoolApp";

       // Send the actual notification
      apnProvider.send(notification, result.deviceToken).then( result => {
        // Sends a push notifications to the other party that their ride has been cancelled.
      // Show the result of the send operation:
         console.log(result);
      });
    })
    .catch(function(error){
        console.log('Error Cancelling Ride:', error)
    });
    res.status(200)
      .json({
        status: 'Success',
        message: 'Driver Route Stored'
      });

  })
}


// Case to handle cancelling a ride series.
else {
    db.query(`DELETE from carpool.\"scheduledRoutes\" where \"matchID\" = '${matchID}'`) // Delete all scheduled routes associated with the match.
    .then( function (){
      db.query(`DELETE from carpool.\"Matches\" where \"matchID\" = ${matchID}`) // delete from Matches table.
      .then(function(){
        db.query(`UPDATE carpool.\"Routes\" SET \"Matched\" = 'false' where \"routeID\" = ${cancelJSON['riderRouteID']} or \"routeID\" = ${cancelJSON['driverRouteID']}`) // sets route to not matched so they are available for matching again.
        db.one(`SELECT \"deviceToken\", \"firstName\" from carpool.\"Users\" where \"userID\" = '${otherID}'`)
        .then(function(result) {
          let notification = new apn.Notification();
           notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600; // will expire in 24 hours from now
          notification.badge = 2;
          notification.sound = "ping.aiff";
          notification.alert = `Your ride series with ${result.firstName} has been cancelled.`;
          notification.payload = {'messageFrom': 'Notifications are working!'};

           // Replace this with your app bundle ID:
           notification.topic = "com.CSC4996.CarpoolApp";

           // Send the actual notification
          apnProvider.send(notification, result.deviceToken).then( result => {
          // Show the result of the send operation:
          // Sends a notification to the other party that the ride series has been cancelled.
             console.log(result);
          });
        })
      })
    })
    .catch(function(error){
        console.log('Error Cancelling Ride:', error)
    });
    res.status(200)
      .json({
        status: 'Success',
        message: 'Driver Route Stored'
      });

}
})



// This POST request is to store routes entered by both riders and drivers
router.post('/', function(req, res, next) {
 var routeInfo = req.body.routeInfo;
 var routeJSON = JSON.parse(routeInfo);
 var userID = routeJSON['userID'];
 console.log(routeJSON);


 if (routeJSON['Driver'] == true) // Handles Driver Routes
  {
    // Inserts Route into the Routes table.
    var addDriverRouteQuery = "INSERT INTO carpool.\"Routes\"(\"driverID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\", \"Matched\", \"Driver\", \"startAddress\", \"endAddress\") values($1, $2, $3, $4, $5, $6, $7, $8, $9, 'false', 'true', $10, $11)"; // this is the query to add driver's route.
    db.any(addDriverRouteQuery, [userID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name'], routeJSON['Days'], routeJSON['startAddress'], routeJSON['endAddress']])
      .then(function () {
        console.log("Driver route added.");
        var setGeographyQuery = "UPDATE carpool.\"Routes\" SET startPoint = ST_POINT (\"startPointLat\", \"startPointLong\"), endPoint = ST_POINT (\"endPointLat\", \"endPointLong\")"; // Set geography object based on coordinates added by user.
        db.none(setGeographyQuery)
        .then(function () {
          console.log("Geographies Set.");
        });
        res.status(200)
          .json({
            status: 'Success',
            message: 'Driver Route Stored'
          });
      })
   .catch(function(error){
       console.log('error selecting driverID:', error)
   });



 }


// Handles rider routes case.
 else {
     db.any(`SELECT * FROM carpool.\"Routes\" WHERE ST_DWithin(startPoint, Geography(ST_MakePoint(${routeJSON['Latitudes'][0]}, ${routeJSON['Longitudes'][0]})),4830) AND ST_DWithin(endPoint, Geography(ST_MakePoint(${routeJSON['Latitudes'][1]}, ${routeJSON['Longitudes'][1]})),4830) AND (\"departureTime\" <= ('${convertTo24Hour(routeJSON['departureTime'])}') AND \"departureTime\" >= ('${convertTo24Hour(routeJSON['departureTime'])}'  - interval '15 minutes')) AND (\"arrivalTime\" <= ('${convertTo24Hour(routeJSON['arrivalTime'])}' + interval '15 minutes') AND \"arrivalTime\" >= ('${convertTo24Hour(routeJSON['arrivalTime'])}')) AND \"Matched\" = 'false' AND \"Driver\" = 'true' and \"Days\" = $1 AND \"driverID\"<> '${userID}'`, [routeJSON['Days']])
     // Query to find all drivers whose routes are within a 3 mile radius of start and endpoint, within 15 minute time interval of arrival and departure, perfect match for days, and not the same rider and driver.)
     .then(function(result) {
       if (result.length > 0){
            //console.log('Match Found: ', result);
            for (var key in result) {
              if (!result.hasOwnProperty(key))
                continue; // traverse through result.
              else{
              var obj = result[key];
              var leg1, leg2, leg3, leg1Distance, leg2Distance, leg3Distance;
              getFirstLeg(); // We use separate functions to calculate each separate leg of the route.


              function getFirstLeg()  // calculates the route distance and ETA of driver start point to rider start point.
              {
              distance.get({
                  origin: `${obj['startPointLat']}, ${obj['startPointLong']}`,
                  destination: `${routeJSON['Latitudes'][0]}, ${routeJSON['Longitudes'][0]}`,
                },
                function(err, data) {
                    if (err) return console.log(err);
                    leg1 = data.duration;
                    leg1Distance = data.distanceValue;
                    getSecondLeg(leg1, leg1Distance); // we use these embedded function calls to make sure each asynchronous request is handled sequentially.
                  });
                }
            function getSecondLeg(leg1, leg1Distance){  // calculates the route distance and ETA of rider start point to rider end point.
              distance.get({
                  origin: `${routeJSON['Latitudes'][0]}, ${routeJSON['Longitudes'][0]}`,
                  destination: `${routeJSON['Latitudes'][1]}, ${routeJSON['Longitudes'][1]}`,
                    },
                    function(err, data) {
                        if (err) return console.log(err);
                        leg2 = data.duration;
                        leg2Distance = data.distanceValue;
                        getThirdLeg(leg1, leg1Distance, leg2, leg2Distance);
                      });
                    }

                    function getThirdLeg(leg1, leg1Distance, leg2, leg2Distance){  // calculates the route distance and ETA of rider  end point to driver end point.
                      distance.get({
                          origin: `${routeJSON['Latitudes'][1]}, ${routeJSON['Longitudes'][1]}`,
                          destination: `${obj['endPointLat']}, ${obj['endPointLong']}`,
                        },
                        function(err, data) {
                            if (err) return console.log(err);
                            leg3 = data.duration;
                            leg3Distance = data.distanceValue;
                             var totalCost = ((leg1Distance + leg2Distance + leg3Distance) / 1000) * 0.335;
                             var driverLeaveTime = `time '${obj['arrivalTime']}'  - (interval '${leg1}'  + interval '${leg2}' + '${leg3}')`; // PostgreSQL queries to calculate route times using time arithmetic.
                             var riderPickup = `${driverLeaveTime} + interval '${leg1}'`;
                             var riderDropOff = `${riderPickup} +  interval '${leg2}'`;
                             var riderPickup2 = `time '${obj['departureTime']}' + interval '${leg3}'`;
                             insertMatches(driverLeaveTime, riderPickup, riderDropOff, riderPickup2, totalCost);
                          });
                        }

                        function insertMatches(driverLeaveTime, riderPickup, riderDropOff, riderPickup2, totalCost){ // after all 3 legs are calculated, insert data into matches table.
                        db.one("SELECT last_value as \"currval\" from \"riderRoutes_routeID_seq\"") // get the rider route ID in the current route table.
                              .then(function(data2){
                                  var riderRouteID = parseInt(data2.currval);
                                  db.one(`select ${driverLeaveTime} as \"driverLeaveTime\"`)
                                   .then(function(driverLeave){
                                     db.one(`select ${riderPickup} as \"riderPickupTime\"`)
                                     .then(function(riderPickupTime){
                                      db.one(`select ${riderDropOff} as \"riderDropOffTime\"`)
                                      .then(function(riderDropOffTime){
                                   db.one(`select ${riderPickup2} as \"riderPickup2Time\"`)
                                      .then(function(riderPickup2Time){
                                db.query(`INSERT INTO carpool.\"Matches\"(\"riderID\", \"driverID\",  \"driverRouteID\", \"Status\", \"riderRouteID\", \"driverLeaveTime\", \"riderPickupTime\", \"riderDropOffTime\", \"riderPickupTime2\", \"rideCost\") values('${userID}', '${obj['driverID']}', ${obj['routeID']}, '${"Awaiting rider request."}', ${riderRouteID}, '${driverLeave.driverLeaveTime}', '${riderPickupTime.riderPickupTime}', '${riderDropOffTime.riderDropOffTime}', '${riderPickup2Time.riderPickup2Time}', ${totalCost})`); // insert rider and driver details into Matches table.
                                });
                                });
                              });
                            });
                          });
                        }
}
}
db.any(`INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ('${userID}', 'Match', 'now', 'false')`); // Insert a notification into table when there is a match.
db.one(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${userID}'`) // we need device token to target specific users with push notifications.
.then(function(result) {
  let notification = new apn.Notification();
   notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600; // will expire in 24 hours from now
  notification.badge = 2;
  notification.sound = "ping.aiff";
  notification.alert = "You have a new match!";
  notification.payload = {'messageFrom': 'Notifications are working!'};

   // Replace this with your app bundle ID:
   notification.topic = "com.CSC4996.CarpoolApp";

   // Send the actual notification
  apnProvider.send(notification, result.deviceToken).then( result => {
  // Show the result of the send operation:
     console.log(result);
  });
})
          }
       else {
          console.log("No match found.");
       }
     });
    // insert Rider's route into Route table.
    db.any(`INSERT INTO carpool.\"Routes\"(\"riderID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\", \"Matched\", \"Driver\", \"startAddress\", \"endAddress\") values('${userID}', '${routeJSON['departureTime']}', '${routeJSON['arrivalTime']}', ${routeJSON['Longitudes'][0]}, ${routeJSON['Latitudes'][0]}, ${routeJSON['Longitudes'][1]}, ${routeJSON['Latitudes'][1]}, '${routeJSON['Name']}', $1, 'false', 'false', '${routeJSON['startAddress']}', '${routeJSON['endAddress']}')`, [routeJSON['Days']])
      .then(function () {
        console.log("Succesfully added route.");
        var setGeographyQuery = "UPDATE carpool.\"Routes\" SET startPoint = ST_POINT (\"startPointLat\", \"startPointLong\"), endPoint = ST_POINT (\"endPointLat\", \"endPointLong\")"; // Set geography objects based on coordinates entered by user.
        db.none(setGeographyQuery)
        .then(function () {
          console.log("Geographies Set.");
        });


        res.status(200)
          .json({
            status: 'Success',
            message: 'Rider route stored.'
          });
      })

      .catch(function (err) {
        console.log('error adding route:', err);
      });

 }

});





module.exports = router;
