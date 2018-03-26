var express = require('express');
var router = express.Router();

const db = require('../routes/db');
const pgp = db.$config.pgp;
const apnModule = require('../routes/apn');
const apn = apnModule.apn;
const apnProvider = apnModule.apnProvider;

router.post('/approval', function(req, res, next) {
 var requestInfo = req.body.requestInfo
 var requestJSON = JSON.parse(requestInfo);
 var userID = requestJSON['userID'];
 var matchID = requestJSON['matchID'];


if (requestJSON['requestType'] == 'riderRequest') // If the rider has requested a driver
{

  db.query("UPDATE carpool.\"Matches\" SET \"Status\" = 'driverRequested' where \"matchID\" = $1", [matchID]) // update match to driver requested.
   .then(function () {
     db.one("SELECT \"driverID\" from carpool.\"Matches\" where \"matchID\" = $1", [matchID])
     .then(function(data) {
        db.any("INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ($1, $2, $3, $4)", [data.driverID, "Match", 'now', 'false']);
        db.one("SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = $1", [data.driverID])
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

 else {
   db.query("UPDATE carpool.\"Matches\" SET \"Status\" = 'Matched' where \"matchID\" = $1", [matchID]) // If the request was a driver approving a request, switch the request status to matched.
   .then(function () {
     db.one("SELECT \"riderID\" from carpool.\"Matches\" where \"matchID\" = $1", [matchID])
     .then(function(data) {
        db.any("INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ($1, $2, $3, $4)", [data.riderID, "Match", 'now', 'false']);
        db.one("SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = $1", [data.riderID])
        .then(function(result) {
          let notification = new apn.Notification();
           notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600; // will expire in 24 hours from now
          notification.badge = 2;
          notification.sound = "ping.aiff";
          notification.alert = "Your ride request has been approved!";
          notification.payload = {'messageFrom': 'CarPool'};

           // Replace this with your app bundle ID:
           notification.topic = "com.CSC4996.CarpoolApp";

           // Send the actual notification
          apnProvider.send(notification, result.deviceToken).then( result => {
          // Show the result of the send operation:
             console.log(result);
          });


          db.query("UPDATE carpool.\"Routes\" SET \"Matched\" = 'true' where \"routeID\" = $1", [requestJSON['driverRouteID']]) // Update the matched column in driver route.
          .then(function() {
                db.query("UPDATE carpool.\"Routes\" SET \"Matched\" = 'true' where \"routeID\" = $1", [requestJSON['riderRouteID']])
                .then(function() {
                  var numOfDays =  requestJSON['Days'].length;
                  console.log("Number of Days", numOfDays);
                  for (var i = 0; i < numOfDays; i++) {
                    if (requestJSON['Days'][i] == 'sunday')
                    {
                      db.query("select d::date from generate_series(current_date + cast(abs(extract(dow from current_date) - 7) as int), current_date + cast(abs(extract(dow from current_date) - 7) as int) + interval '1 year', '1 week'::interval) d")
                        .then(function(result) {
                          var resultDates = result.length;
                          console.log("Results Length", resultDates);
                          for (var y = 0; y < resultDates; y++)
                          {
                            db.query("INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\") values ('sunday', $1, 'Scheduled', $2)", [matchID, result[y].d])
                            .catch(function (err) {
                              console.log(err);
                            });

                          }
                        })
                    }
                      if (requestJSON['Days'][i] == 'monday')
                      {
                        db.query("select d::date from generate_series(current_date + cast(abs(extract(dow from current_date) - 7) + 1 as int), current_date + cast(abs(extract(dow from current_date) - 7) + 1 as int) + interval '1 year', '1 week'::interval) d")
                          .then(function(result) {
                            var resultDates = result.length;
                            console.log("Results Length", resultDates);
                            for (var y = 0; y < resultDates; y++)
                            {
                              db.query("INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\") values ('monday', $1, 'Scheduled', $2)", [matchID, result[y].d])
                              .catch(function (err) {
                                console.log(err);
                              });

                            }
                          })
                      }
                      if (requestJSON['Days'][i] == 'tuesday')
                      {
                        db.query("select d::date from generate_series(current_date + cast(abs(extract(dow from current_date) - 7) + 2 as int), current_date + cast(abs(extract(dow from current_date) - 7) + 2 as int) + interval '1 year', '1 week'::interval) d")
                          .then(function(result) {
                            var resultDates = result.length;
                            console.log("Results Length", resultDates);
                            for (var y = 0; y < resultDates; y++)
                            {
                              db.query("INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\") values ('tuesday', $1, 'Scheduled', $2)", [matchID, result[y].d])
                              .catch(function (err) {
                                console.log(err);
                              });

                            }
                          })
                      }


                      if (requestJSON['Days'][i] == 'wednesday')
                      {
                        db.query("select d::date from generate_series(current_date + cast(abs(extract(dow from current_date) - 7) + 3 as int), current_date + cast(abs(extract(dow from current_date) - 7) + 3 as int) + interval '1 year', '1 week'::interval) d")
                          .then(function(result) {
                            var resultDates = result.length;
                            console.log("Results Length", resultDates);
                            for (var y = 0; y < resultDates; y++)
                            {
                              db.query("INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\") values ('wednesday', $1, 'Scheduled', $2)", [matchID, result[y].d])
                              .catch(function (err) {
                                console.log(err);
                              });

                            }
                          })
                      }

                      if (requestJSON['Days'][i] == 'thursday')
                      {
                        db.query("select d::date from generate_series(current_date + cast(abs(extract(dow from current_date) - 7) + 4 as int), current_date + cast(abs(extract(dow from current_date) - 7) + 4 as int) + interval '1 year', '1 week'::interval) d")
                          .then(function(result) {
                            var resultDates = result.length;
                            console.log("Results Length", resultDates);
                            for (var y = 0; y < resultDates; y++)
                            {
                              db.query("INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\") values ('thursday', $1, 'Scheduled', $2)", [matchID, result[y].d])
                              .catch(function (err) {
                                console.log(err);
                              });

                            }
                          })
                      }

                      if (requestJSON['Days'][i] == 'friday')
                      {
                        db.query("select d::date from generate_series(current_date + cast(abs(extract(dow from current_date) - 7) + 5 as int), current_date + cast(abs(extract(dow from current_date) - 7) + 5 as int) + interval '1 year', '1 week'::interval) d")
                          .then(function(result) {
                            var resultDates = result.length;
                            console.log("Results Length", resultDates);
                            for (var y = 0; y < resultDates; y++)
                            {
                              db.query("INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\") values ('friday', $1, 'Scheduled', $2)", [matchID, result[y].d])
                              .catch(function (err) {
                                console.log(err);
                              });

                            }
                          })
                      }

                      if (requestJSON['Days'][i] == 'saturday')
                      {
                        db.query("select d::date from generate_series(current_date + cast(abs(extract(dow from current_date) - 7) + 6 as int), current_date + cast(abs(extract(dow from current_date) - 7) + 6 as int) + interval '1 year', '1 week'::interval) d")
                          .then(function(result) {
                            var resultDates = result.length;
                            console.log("Results Length", resultDates);
                            for (var y = 0; y < resultDates; y++)
                            {
                              db.query("INSERT INTO carpool.\"scheduledRoutes\"(\"Day\", \"matchID\", \"Status\", \"Date\") values ('saturday', $1, 'Scheduled', $2)", [matchID, result[y].d])
                              .catch(function (err) {
                                console.log(err);
                              });

                            }
                          })
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



router.get('/', function(req, res, next) {
var userID = req.query.userID;
 // Select all drivers the rider has matched with so they can request one.
var matchesQuery = "select distinct on (\"matchID\") * from (select \"firstName\" as \"riderFirstName\", \"lastName\" as \"riderLastName\", \"Biography\" as \"riderBiography\", \"userID\" from carpool.\"Users\")g JOIN ((select \"startPointLat\" as \"riderStartPointLat\", \"startPointLong\" as \"riderStartPointLong\", \"endPointLat\" as \"riderEndPointLat\", \"endPointLong\" as \"riderEndPointLong\", \"riderID\" as \"riderRouteUserID\", \"Days\" as \"riderDays\", \"arrivalTime\" as \"riderArrival\", \"departureTime\" as \"riderDeparture\", \"Name\" as \"riderRouteName\", \"routeID\" from carpool.\"Routes\")e JOIN ((select \"startPointLat\" as \"driverStartPointLat\", \"startPointLong\" as \"driverStartPointLong\", \"endPointLat\" as \"driverEndPointLat\", \"endPointLong\" as \"driverEndPointLong\",\"driverID\" as \"driverRouteUserID\",\"Days\" as \"driverDays\",\"arrivalTime\" as \"driverArrival\",\"departureTime\" as \"driverDeparture\",\"Name\" as \"driverRouteName\",\"routeID\" from carpool.\"Routes\") d  JOIN ((select * from carpool.\"Matches\" where (\"riderID\" = $1 AND \"Status\" = 'Awaiting rider request.') OR (\"driverID\" = $1 AND \"Status\" = 'driverRequested') ) a  JOIN (select \"firstName\" as \"driverFirstName\", \"lastName\" as \"driverLastName\",\"Biography\" as \"driverBiography\",\"userID\" from carpool.\"Users\")b  ON a.\"driverID\" = b.\"userID\")c  ON c.\"driverRouteID\" = d.\"routeID\")f ON e.\"riderRouteUserID\" = f.\"riderID\")h ON g.\"userID\" = h.\"riderID\"";
db.query(matchesQuery, userID)
.then(function(data) {
  res.send(data);
  });
});






module.exports = router;
