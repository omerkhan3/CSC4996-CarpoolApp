var express = require('express');
var router = express.Router();

const db = require('../routes/db'); // configures our connection to the DB.
const pgp = db.$config.pgp;
const apnModule = require('../routes/apn'); // Allows us to connect to Apple Push Notification Service.
const apn = apnModule.apn;
const apnProvider = apnModule.apnProvider;

require('datejs')

var distance = require('google-distance-matrix');

const baseEpoch = 1535947200; // Monday September 3, 2018 12:00 AM

distance.key('AIzaSyBmaYe1priemqk2O-mcT5UPA0lJZpCzRQg');


function convertToEpoch(time)
{
  var sep = time.split(':');
  var seconds = (+sep[0]) * 60 * 60 + (+sep[1]) * 60 + (+sep[2]);
  return seconds;
}


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

function sendPushNotification(message, deviceToken, otherID)
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


// This GET request returns all routes a user has previously entered.
router.get('/saved', function(req, res, next) {
var userID = req.query.userID;
db.query(`select * from carpool.\"Routes\" where \"driverID\" = '${userID}' OR \"riderID\" = '${userID}'`)
.then(function(data) {
 res.send(data);
  });
});

//This post method will delete a single route from the database
router.post('/cancelRoute', function(req, res, next) {
  var cancelrouteInfo = req.body.cancelrouteInfo;
	var cancelRouteJSON = JSON.parse(cancelrouteInfo);
	console.log(cancelRouteJSON);
		db.query(`DELETE from carpool.\"Routes\" where \"routeID\" = ${cancelRouteJSON['routeID']}`)
    .then(function() {
      res.status(200)
        .json({
          status: 'Success',
          message: 'Route deleted'
        });
      })
      .catch(function(error){
          console.log('Error deleting routeID', error);
      });
    });



//This GET request returns all routes a user is currently scheduled for.
router.get('/scheduled', function(req, res, next) {
var userID = req.query.userID;
db.query(`select \"rideCost\", \"driverFirstName\", \"driverStartAddress\", \"driverEndAddress\", \"driverStartPointLat\", \"driverStartPointLong\", \"driverEndPointLat\", \"driverEndPointLong\", \"riderFirstName\", \"riderStartAddress\", \"riderEndAddress\", \"riderStartPointLat\", \"riderStartPointLong\", \"riderEndPointLat\", \"riderEndPointLong\", \"matchID\", \"Day\", \"Date\", \"driverRouteID\",  \"riderRouteID\", \"riderID\", \"driverID\", \"riderPickupTime\", \"riderDropOffTime\", \"driverLeaveTime\", \"riderPickupTime2\", \"driverRouteName\", \"riderRouteName\", \"routeType\", \"driverDepartureTime1\" from (select \"firstName\" as \"riderFirstName\", \"userID\" from carpool.\"Users\") h JOIN ((select \"firstName\" as \"driverFirstName\", \"userID\" from carpool.\"Users\") h JOIN ((select \"startPointLat\" as \"driverStartPointLat\",  \"startPointLong\" as \"driverStartPointLong\", \"endPointLat\" as \"driverEndPointLat\",  \"endPointLong\" as \"driverEndPointLong\", \"routeID\", \"Name\" as \"driverRouteName\", \"startAddress\" as \"driverStartAddress\", \"endAddress\" as \"driverEndAddress\", \"departureTime1\" as \"driverDepartureTime1\" from carpool.\"Routes\")e JOIN ((select \"startPointLat\" as \"riderStartPointLat\", \"startPointLong\" as \"riderStartPointLong\", \"endPointLat\" as \"riderEndPointLat\",  \"endPointLong\" as \"riderEndPointLong\", \"routeID\", \"Name\" as \"riderRouteName\", \"startAddress\" as \"riderStartAddress\", \"endAddress\" as \"riderEndAddress\" from carpool.\"Routes\") c JOIN ((select \"Day\", \"Date\", \"Status\", \"matchID\" as \"scheduledRideMatchID\", \"routeType\" from carpool.\"scheduledRoutes\" where \"Date\" >= 'now' and \"Status\" != 'CANCELLED') a JOIN (select * from carpool.\"Matches\" where (\"riderID\" = '${userID}' OR \"driverID\" = '${userID}') AND \"Status\" = 'Matched') b ON a.\"scheduledRideMatchID\" = b.\"matchID\")d ON d.\"riderRouteID\" = c.\"routeID\")f ON f.\"driverRouteID\" = e.\"routeID\")g ON g.\"driverID\" = h.\"userID\") j ON j.\"riderID\" = h.\"userID\" ORDER BY \"Date\" LIMIT 20`)
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
 console.log(date.slice(5,10));
  db.query(`UPDATE carpool.\"scheduledRoutes\" SET \"Status\" = 'CANCELLED' where \"Date\" = '${date}' AND \"matchID\" = ${matchID}`)
  .then( function (){
    //var deviceToken = getDeviceID(otherID);
    db.one(`SELECT \"deviceToken\", \"firstName\" from carpool.\"Users\" where \"userID\" = '${otherID}'`)
    .then(function(result) {
      sendPushNotification(`Your ride with ${result.firstName} on ${date.slice(5,10)} has been cancelled.`, result.deviceToken);
      db.any(`INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ('${otherID}', '${result.firstName} has cancelled your ride on ${date.slice(5,10)}.', 'now', 'false')`)
      .then(function(){
        res.status(200)
          .json({
            status: 'Success',
            message: 'Ride Cancelled.'
          });
      })
    })
  })
  .catch(function(error){
      console.log('Error Cancelling Ride:', error)
  });
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
          sendPushNotification(`Your ride series with ${result.firstName} has been cancelled.`, result.deviceToken);
          db.any(`INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ('${otherID}', '${result.firstName} has cancelled your ride series.', 'now', 'false')`)
          .then(function(){
            res.status(200)
              .json({
                status: 'Success',
                message: 'Ride Cancelled.'
              });
          })
        })
      })
    })
    .catch(function(error){
        console.log('Error Cancelling Ride:', error)
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

    db.any(`SELECT * FROM carpool.\"Routes\" WHERE ST_DWithin(startPoint, Geography(ST_MakePoint(${routeJSON['startPointLat']}, ${routeJSON['startPointLong']})),4830) AND ST_DWithin(endPoint, Geography(ST_MakePoint(${routeJSON['endPointLat']}, ${routeJSON['endPointLong']})),4830) AND ((\"departureTime1\" >= '${convertTo24Hour(routeJSON['departureTime1'])}' AND \"departureTime1\" <= '${convertTo24Hour(routeJSON['departureTime2'])}') OR (\"departureTime2\" >= '${convertTo24Hour(routeJSON['departureTime1'])}' AND \"departureTime2\"<= '${convertTo24Hour(routeJSON['departureTime2'])}')) AND ((\"arrivalTime2\"  >= '${convertTo24Hour(routeJSON['arrivalTime1'])}' AND \"arrivalTime2\" <= '${convertTo24Hour(routeJSON['arrivalTime2'])}') OR (\"arrivalTime1\"  >= '${convertTo24Hour(routeJSON['arrivalTime1'])}' AND \"arrivalTime1\" <= '${convertTo24Hour(routeJSON['arrivalTime2'])}')) AND \"Matched\" = 'false' AND \"Driver\" = 'false' AND \"riderID\"<> '${userID}'`)
    // Query to find all drivers whose routes are within a 3 mile radius of start and endpoint, within 15 minute time interval of arrival and departure, perfect match for days, and not the same rider and driver.)
    .then(function(result) {
      if (result.length > 0){
           //console.log('Match Found: ', result);
           for (var key in result) {
             if (!result.hasOwnProperty(key))
               continue; // traverse through result.
             else{
             var obj = result[key];
             var matchedDays = routeJSON['Days'].filter(function(n) {
                 return obj['Days'].indexOf(n) > -1;
                 });
             console.log(matchedDays);
             if (matchedDays === undefined || matchedDays.length == 0){
               continue;
             }
             var leg1Duration, leg2Duration, leg3Duration, leg1Distance, leg2Distance, leg3Distance, driverArrivalTime2, leg2_startTime, leg1_startTime;
             getThirdLeg(); // We use separate functions to calculate each separate leg of the route.


             function getThirdLeg(){
                // Convert driver arrival time to epoch & set as parameter
                 driverArrivalTime2 = convertTo24Hour(`${routeJSON['arrivalTime2']}`);
                 leg3_epoch_arrivalTime2 = convertToEpoch(driverArrivalTime2) + baseEpoch;

                 // set parameter
                 distance.departure_time(leg3_epoch_arrivalTime2);
                 distance.units('imperial');

                 // Driver final destination to rider final destination
                 var leg3_origin = [`${routeJSON['endPointLat']}, ${routeJSON['endPointLong']}`]; // driver
                 var leg3_destination =  [`${obj['endPointLat']}, ${obj['endPointLong']}`]; // rider
                 //var leg3_destination =  ['2151 Kennedy Drive 48309']; // rider

                 // Distance matrix api query
                 distance.matrix(leg3_origin, leg3_destination, function (err, distances) {
                   if (err) {
                       return console.log(err);
                   }
                   if(!distances) {
                       return console.log('no distances');
                   }
                   if (distances.status == 'OK') {
                       var origin = distances.origin_addresses[0];
                       var destination = distances.destination_addresses[0];
                       if (distances.rows[0].elements[0].status == 'OK') {
                           leg3Duration = distances.rows[0].elements[0].duration;
                           leg3Distance = distances.rows[0].elements[0].distance;

                           if (leg3Distance == null)
                           {
                             leg3Distance = 0;
                           }
                           getSecondLeg(driverArrivalTime2, leg3Duration, leg3Distance);
                       } else {
                           console.log(destination + ' is not reachable by land from ' + origin);
                       }
                     }
                  });
              }

              function getSecondLeg(driverArrivalTime2, leg3Duration, leg3Distance){  // calculates the route distance and ETA of rider start point to rider end point.
                leg2_startTime = convertToEpoch(driverArrivalTime2) - leg3Duration.value + baseEpoch; // in seconds (epoch)
                leg2_epochDeparture = leg2_startTime;
                distance.departure_time(leg2_epochDeparture);
                distance.units('imperial');

                 var leg2_origin = [`${obj['endPointLat']}, ${obj['endPointLong']}`]; // Rider end location
                 var leg2_destination = [`${obj['startPointLat']}, ${obj['startPointLong']}`]; // Rider start location

                 distance.matrix(leg2_origin, leg2_destination, function (err, distances) {
                   if (err) {
                       return console.log(err);
                   }
                   if(!distances) {
                       return console.log('no distances');
                   }
                   if (distances.status == 'OK') {
                       var origin = distances.origin_addresses[0];
                       var destination = distances.destination_addresses[0];
                       if (distances.rows[0].elements[0].status == 'OK') {
                           leg2Duration = distances.rows[0].elements[0].duration;
                           leg2Distance = distances.rows[0].elements[0].distance;
                           getFirstLeg(leg2_startTime, leg3Duration, leg3Distance, leg2Duration, leg2Distance);
                       } else {
                           console.log(destination + ' is not reachable by land from ' + origin);
                       }
                   }
                 });
                }

             function getFirstLeg(leg2_startTime, leg3Duration, leg3Distance, leg2Duration, leg2Distance)  // calculates the route distance and ETA of driver start point to rider start point.
             {
               // Convert driver arrival time to epoch time & set parameter
               leg1_startTime = leg2_startTime - leg2Duration.value;
               distance.arrival_time(leg1_startTime); //set API query parameter
               distance.units('imperial');

               // Define origin and destination arrays
               var leg1_origin = [`${obj['startPointLat']}, ${obj['startPointLong']}`];
               var leg1_destination = [`${routeJSON['startPointLat']}, ${routeJSON['startPointLong']}`];

               distance.matrix(leg1_origin, leg1_destination, function (err, distances) {
                 if (err) {
                     return console.log(err);
                 }
                 if(!distances) {
                     return console.log('no distances');
                 }
                 if (distances.status == 'OK') {
                     var origin = distances.origin_addresses[0];
                     var destination = distances.destination_addresses[0];
                     if (distances.rows[0].elements[0].status == 'OK') {
                         leg1Duration = distances.rows[0].elements[0].duration;
                         leg1Distance = distances.rows[0].elements[0].distance;

                         getReturnLeg1(leg2_startTime, leg3Duration, leg3Distance, leg2Duration, leg2Distance, leg1Duration, leg1Distance)

                     } else {
                         console.log(destination + ' is not reachable by land from ' + origin);
                     }
                 }
               });
               }

               function getReturnLeg1(leg2_startTime, leg3Duration, leg3Distance, leg2Duration, leg2Distance, leg1Duration, leg1Distance) {
                 return_startTime = convertTo24Hour(`${routeJSON['departureTime2']}`);
                 return_startTimeEpoch = convertToEpoch(return_startTime) + baseEpoch;
                 console.log("departure time: ", return_startTimeEpoch);
                 distance.departure_time(return_startTimeEpoch); //set API query parameter
                distance.units('imperial');

                // Driver final destination to rider final destination
                var returnLeg1_origin = [`${routeJSON['endPointLat']}, ${routeJSON['endPointLong']}`]; // driver
                var returnLeg1_destination =  [`${obj['endPointLat']}, ${obj['endPointLong']}`]; // rider

                // Distance matrix api query
                distance.matrix(returnLeg1_origin, returnLeg1_destination, function (err, distances) {
                  if (err) {
                      return console.log(err);
                  }
                  if(!distances) {
                      return console.log('no distances');
                  }
                  if (distances.status == 'OK') {
                      var origin = distances.origin_addresses[0];
                      var destination = distances.destination_addresses[0];
                      if (distances.rows[0].elements[0].status == 'OK') {
                          returnLeg1Duration = distances.rows[0].elements[0].duration;
                          returnLeg1Distance = distances.rows[0].elements[0].distance;

                          if (leg3Distance == null)
                          {
                            leg3Distance = 0;
                          }
                          var totalCost = (leg2Distance.value / 1000) * 0.62 * 0.335 ;
                          var totalDuration = leg1Duration.value + leg2Duration.value + leg3Duration.value;
                          var totalDurationText = totalDuration + " seconds";
                          var driverLeaveTime = `time '${routeJSON['arrivalTime2']}'  - interval '${totalDurationText}'`;
                          var driverDepartTime = `${routeJSON['departureTime2']}`;
                          var riderPickup = `${driverLeaveTime} + interval '${leg1Duration.value} seconds'`;
                          var riderDropOff = `${riderPickup} +  interval '${leg2Duration.value} seconds'`;
                          var riderPickup2 = `time '${routeJSON['departureTime2']}' - interval '${returnLeg1Duration.value} seconds'`;

                        insertMatches(driverLeaveTime, riderPickup, riderDropOff, riderPickup2, totalCost);
                      } else {
                          console.log(destination + ' is not reachable by land from ' + origin);
                      }
                    }
                 });
               }

               function insertMatches(driverLeaveTime, riderPickup, riderDropOff, riderPickup2, totalCost){ // after all 3 legs are calculated, insert data into matches table.
               db.one("SELECT last_value as \"currval\" from \"riderRoutes_routeID_seq\"") // get the rider route ID in the current route table.
                     .then(function(data2){
                         var driverRouteID = parseInt(data2.currval);
                         db.one(`select ${driverLeaveTime} as \"driverLeaveTime\"`)
                          .then(function(driverLeave){
                            db.one(`select ${riderPickup} as \"riderPickupTime\"`)
                            .then(function(riderPickupTime){
                             db.one(`select ${riderDropOff} as \"riderDropOffTime\"`)
                             .then(function(riderDropOffTime){
                          db.one(`select ${riderPickup2} as \"riderPickup2Time\"`)
                             .then(function(riderPickup2Time){
                          var riderStartInterval1 = Date.parse(obj['arrivalTime1']);
                          var riderStartInterval2 = Date.parse(obj['arrivalTime2']);
                          var riderEndInterval1 = Date.parse(obj['departureTime1']);
                          var riderEndInterval2 = Date.parse(obj['departureTime2']);
                          var riderArrivalTime = Date.parse(riderDropOffTime.riderDropOffTime);
                          var riderDepartureTime = Date.parse(riderPickup2Time.riderPickup2Time);

                          if (riderArrivalTime.between(riderStartInterval1, riderStartInterval2) == true && riderDepartureTime.between(riderEndInterval1, riderEndInterval2) ==  true){
                            db.query(`INSERT INTO carpool.\"Matches\"(\"riderID\", \"driverID\",  \"driverRouteID\", \"Status\", \"riderRouteID\", \"driverLeaveTime\", \"riderPickupTime\", \"riderDropOffTime\", \"riderPickupTime2\", \"rideCost\", \"matchedDays\") values('${obj['riderID']}', '${userID}', ${driverRouteID}, '${"Awaiting rider request."}', ${obj['routeID']} , '${driverLeave.driverLeaveTime}', '${riderPickupTime.riderPickupTime}', '${riderDropOffTime.riderDropOffTime}', '${riderPickup2Time.riderPickup2Time}', ${totalCost}, $1)`, [matchedDays]);
                            // insert rider and driver details into Matches table.


                             db.any(`INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ('${obj['riderID']}', 'You have a new match!', 'now', 'false')`);
                            db.one(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${obj['riderID']}'`) // we need device token to target specific users with push notifications.
                            .then(function(result) {
                              sendPushNotification("You have a new match!", result.deviceToken);
                            })
                          }

                          else{
                            console.log("Calculated route times do not comply with rider intervals.");
                          }



                          });
                       });
                     });
                   });
                 });
              }
          }}
        }
      else {
         console.log("No match found.");
      }
    });

    // Inserts Route into the Routes table.
    var addDriverRouteQuery = "INSERT INTO carpool.\"Routes\"(\"driverID\", \"departureTime1\", \"departureTime2\", \"arrivalTime1\", \"arrivalTime2\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\", \"Matched\", \"Driver\", \"startAddress\", \"endAddress\") values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'false', 'true', $12, $13)"; // this is the query to add driver's route.
    db.any(addDriverRouteQuery, [userID, routeJSON['departureTime1'], routeJSON['departureTime2'], routeJSON['arrivalTime1'], routeJSON['arrivalTime2'], routeJSON['startPointLong'], routeJSON['startPointLat'], routeJSON['endPointLong'], routeJSON['endPointLat'], routeJSON['Name'], routeJSON['Days'], routeJSON['startAddress'], routeJSON['endAddress']])
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
     db.any(`SELECT * FROM carpool.\"Routes\" WHERE ST_DWithin(startPoint, Geography(ST_MakePoint(${routeJSON['startPointLat']}, ${routeJSON['startPointLong']})),4830) AND ST_DWithin(endPoint, Geography(ST_MakePoint(${routeJSON['endPointLat']}, ${routeJSON['endPointLong']})),4830) AND ((\"departureTime1\" <= '${convertTo24Hour(routeJSON['departureTime1'])}' AND \"departureTime2\" >= '${convertTo24Hour(routeJSON['departureTime1'])}') OR (\"departureTime1\" <= '${convertTo24Hour(routeJSON['departureTime2'])}' AND \"departureTime2\" >= '${convertTo24Hour(routeJSON['departureTime2'])}')) AND ((\"arrivalTime1\" <= '${convertTo24Hour(routeJSON['arrivalTime2'])}' AND \"arrivalTime2\" >= '${convertTo24Hour(routeJSON['arrivalTime2'])}') OR (\"arrivalTime1\" <= '${convertTo24Hour(routeJSON['arrivalTime1'])}' AND \"arrivalTime2\" >= '${convertTo24Hour(routeJSON['arrivalTime1'])}')) AND \"Matched\" = 'false' AND \"Driver\" = 'true' AND \"driverID\"<> '${userID}'`)
     // Query to find all drivers whose routes are within a 3 mile radius of start and endpoint, within 15 minute time interval of arrival and departure, perfect match for days, and not the same rider and driver.)
     .then(function(result) {
       if (result.length > 0){
            //console.log('Match Found: ', result);
            for (var key in result) {
              if (!result.hasOwnProperty(key))
                continue; // traverse through result.
              else{
              var obj = result[key];
              var matchedDays = routeJSON['Days'].filter(function(n) {
                  return obj['Days'].indexOf(n) > -1;
                  });
              console.log(matchedDays);
              if (matchedDays === undefined || matchedDays.length == 0){
                continue;
              }

              var leg1Duration, leg2Duration, leg3Duration, leg1Distance, leg2Distance, leg3Distance, driverArrivalTime2, leg2_startTime, leg1_startTime;
              //getFirstLeg(); // We use separate functions to calculate each separate leg of the route.

              getThirdLeg(); // We use separate functions to calculate each separate leg of the route.


             function getThirdLeg(){
                // Convert driver arrival time to epoch & set as parameter
                 driverArrivalTime2 = convertTo24Hour(`${routeJSON['arrivalTime2']}`);
                 leg3_epoch_arrivalTime2 = convertToEpoch(driverArrivalTime2) + baseEpoch;
                 // set parameter
                 distance.departure_time(leg3_epoch_arrivalTime2);
                 distance.units('imperial');

                 // Driver final destination to rider final destination
                 var leg3_origin = [`${obj['endPointLat']}, ${obj['endPointLong']}`]; // driver end
                 var leg3_destination =  [`${routeJSON['endPointLat']}, ${routeJSON['endPointLong']}`]; // rider end
                 //var leg3_destination =  ['2151 Kennedy Drive 48309']; // rider

                 // Distance matrix api query
                 distance.matrix(leg3_origin, leg3_destination, function (err, distances) {
                   if (err) {
                       return console.log(err);
                   }
                   if(!distances) {
                       return console.log('no distances');
                   }
                   if (distances.status == 'OK') {
                       var origin = distances.origin_addresses[0];
                       var destination = distances.destination_addresses[0];
                       if (distances.rows[0].elements[0].status == 'OK') {
                           leg3Duration = distances.rows[0].elements[0].duration;
                           leg3Distance = distances.rows[0].elements[0].distance;

                           if (leg3Distance == null)
                           {
                             leg3Distance = 0;
                           }
                           getSecondLeg(driverArrivalTime2, leg3Duration, leg3Distance);
                       } else {
                           console.log(destination + ' is not reachable by land from ' + origin);
                       }
                     }
                  });
              }

              function getSecondLeg(driverArrivalTime2, leg3Duration, leg3Distance){  // calculates the route distance and ETA of rider start point to rider end point.

                leg2_startTime = convertToEpoch(driverArrivalTime2) - leg3Duration.value + baseEpoch; // in seconds (epoch)
                leg2_epochDeparture = leg2_startTime;

                distance.departure_time(leg2_epochDeparture);
                distance.units('imperial');

                 var leg2_origin = [`${routeJSON['endPointLat']}, ${routeJSON['endPointLong']}`]; // Rider end location
                 var leg2_destination = [`${routeJSON['startPointLat']}, ${routeJSON['startPointLong']}`]; // Rider start location

                 distance.matrix(leg2_origin, leg2_destination, function (err, distances) {
                   if (err) {
                       return console.log(err);
                   }
                   if(!distances) {
                       return console.log('no distances');
                   }
                   if (distances.status == 'OK') {
                       var origin = distances.origin_addresses[0];
                       var destination = distances.destination_addresses[0];
                       if (distances.rows[0].elements[0].status == 'OK') {
                           leg2Duration = distances.rows[0].elements[0].duration;
                           leg2Distance = distances.rows[0].elements[0].distance;
                           getFirstLeg(leg2_startTime, leg3Duration, leg3Distance, leg2Duration, leg3Distance);
                       } else {
                           console.log(destination + ' is not reachable by land from ' + origin);
                       }
                   }
                 });
                }

             function getFirstLeg(leg2_startTime, leg3Duration, leg3Distance, leg2Duration, leg3Distance)  // calculates the route distance and ETA of driver start point to rider start point.
             {
               // Convert driver arrival time to epoch time & set parameter
               leg1_startTime = leg2_startTime - leg2Duration.value;
               distance.arrival_time(leg1_startTime); //set API query parameter
               distance.units('imperial');

               // Define origin and destination arrays
               var leg1_origin = [`${routeJSON['startPointLat']}, ${routeJSON['startPointLong']}`]; // rider start point
               var leg1_destination = [`${obj['startPointLat']}, ${obj['startPointLong']}`]; // driver start point

               distance.matrix(leg1_origin, leg1_destination, function (err, distances) {
                 if (err) {
                     return console.log(err);
                 }
                 if(!distances) {
                     return console.log('no distances');
                 }
                 if (distances.status == 'OK') {
                     var origin = distances.origin_addresses[0];
                     var destination = distances.destination_addresses[0];
                     if (distances.rows[0].elements[0].status == 'OK') {
                         leg1Duration = distances.rows[0].elements[0].duration;
                         leg1Distance = distances.rows[0].elements[0].distance;
                        var totalDistance = (leg1Distance.value + leg2Distance.value + leg3Distance.value);
                        var totalCost = (totalDistance / 1000) * 0.62 * 0.335 ;
                        var totalDuration = leg1Duration.value + leg2Duration.value + leg3Duration.value;
                        var totalDurationText = totalDuration + " seconds";
                        var driverLeaveTime = `time '${routeJSON['arrivalTime2']}'  - interval '${totalDurationText}'`;
                        var riderPickup = `${driverLeaveTime} + interval '${leg1Duration.value} seconds'`;
                        var riderDropOff = `${riderPickup} +  interval '${leg2Duration.value} seconds'`;
                        var riderPickup2 = `time '${routeJSON['departureTime1']}' + interval '${leg3Duration.value} seconds'`;
                        insertMatches(driverLeaveTime, riderPickup, riderDropOff, riderPickup2, totalCost);

                     } else {
                         console.log(destination + ' is not reachable by land from ' + origin);
                     }
                 }
               });


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

                                        var riderStartInterval1 = Date.parse(routeJSON['arrivalTime1']);
                                        var riderStartInterval2 = Date.parse(routeJSON['arrivalTime2']);
                                        var riderEndInterval1 = Date.parse(routeJSON['departureTime1']);
                                        var riderEndInterval2 = Date.parse(routeJSON['departureTime2']);
                                        var riderArrivalTime = Date.parse(riderDropOffTime.riderDropOffTime);
                                        var riderDepartureTime = Date.parse(riderPickup2Time.riderPickup2Time);

                                        if (riderArrivalTime.between(riderStartInterval1, riderStartInterval2) == true && riderDepartureTime.between(riderEndInterval1, riderEndInterval2) ==  true){
                                          db.query(`INSERT INTO carpool.\"Matches\"(\"riderID\", \"driverID\",  \"driverRouteID\", \"Status\", \"riderRouteID\", \"driverLeaveTime\", \"riderPickupTime\", \"riderDropOffTime\", \"riderPickupTime2\", \"rideCost\", \"matchedDays\") values('${userID}', '${obj['driverID']}', ${obj['routeID']}, '${"Awaiting rider request."}', ${riderRouteID}, '${driverLeave.driverLeaveTime}', '${riderPickupTime.riderPickupTime}', '${riderDropOffTime.riderDropOffTime}', '${riderPickup2Time.riderPickup2Time}', ${totalCost}, $1)`, [matchedDays]); // insert rider and driver details into Matches table.

                                          db.any(`INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ('${userID}', 'You have a new match!', 'now', 'false')`); // Insert a notification into table when there is a match.

                                          db.one(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${userID}'`) // we need device token to target specific users with push notifications.
                                          .then(function(result) {
                                            sendPushNotification("You have a new match!", result.deviceToken);
                                          })
                                        }

                                        else{
                                          console.log("Calculated route times do not comply with rider intervals.");
                                        }


                                });
                                });
                              });
                            });
                          });
                        }
                    }
              } // end of for loop

          }
        }

       else {
          console.log("No match found.");
       }
     });
    // insert Rider's route into Route table.
    db.any(`INSERT INTO carpool.\"Routes\"(\"riderID\", \"departureTime1\", \"departureTime2\",  \"arrivalTime1\", \"arrivalTime2\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\", \"Matched\", \"Driver\", \"startAddress\", \"endAddress\") values('${userID}', '${routeJSON['departureTime1']}', '${routeJSON['departureTime2']}', '${routeJSON['arrivalTime1']}', '${routeJSON['arrivalTime2']}', ${routeJSON['startPointLong']}, ${routeJSON['startPointLat']}, ${routeJSON['endPointLong']}, ${routeJSON['endPointLat']}, '${routeJSON['Name']}', $1, 'false', 'false', '${routeJSON['startAddress']}', '${routeJSON['endAddress']}')`, [routeJSON['Days']])
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
