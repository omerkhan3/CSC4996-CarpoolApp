var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var firebase = require('firebase');
var admin = require('firebase-admin');
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
   db.query("UPDATE carpool.\"Users\" SET \"Status\" = 'Matched' where \"matchID\" = $1", [userJSON[matchID]]) // If the request was a driver approving a request, switch the request status to matched.
    .then(function () {
      db.query("UPDATE carpool.\"Routes\" SET \"Matched\" = 'true' where \"routeID\" = $1", [userJSON['driverRouteID']]) // Update the matched column in driver route.
      .then(function() {
            db.query("UPDATE carpool.\"Routes\" SET \"Matched\" = 'true' where \"routeID\" = $1", [userJSON['riderRouteID']]) // Update the matched column in rider route.
            .catch(function (err) {
              res.send(err);
            });


      res.status(200)
        .json({
          status: 'Success',
          message: 'Match Updated.'
        });
      })
              })

    .catch(function (err) {
      res.send(err);
    });

 }
});



router.get('/', function(req, res, next) {
var userID = req.query.userID;
 // Select all drivers the rider has matched with so they can request one.
var matchesQuery = "select \"driverFirstName\", \"driverLastName\", \"driverBiography\", \"driverID\", \"driverEndPointLat\", \"driverEndPointLong\", \"driverRouteUserID\", \"driverDays\", \"driverArrival\", \"driverDeparture\", \"driverRouteName\", \"driverRouteID\", \"matchID\", \"riderID\" from (select \"endPointLat\" as \"driverEndPointLat\", \"endPointLong\" as \"driverEndPointLong\", \"driverID\" as \"driverRouteUserID\", \"Days\" as \"driverDays\", \"arrivalTime\" as \"driverArrival\", \"departureTime\" as \"driverDeparture\", \"Name\" as \"driverRouteName\", \"routeID\" from carpool.\"Routes\") d JOIN ((select * from carpool.\"Matches\" where \"riderID\" = $1) a JOIN (select \"firstName\" as \"driverFirstName\", \"lastName\" as \"driverLastName\", \"Biography\" as \"driverBiography\", \"userID\" from carpool.\"Users\")b ON a.\"driverID\" = b.\"userID\")c ON c.\"driverRouteID\" = d.\"routeID\"";
db.query(matchesQuery, userID)
.then(function(data) {
  console.log(data);
  res.send(data);
  });
});


router.get('/riderReqests', function(req, res, next){
  var userID = req.query.userID;

  // Select all requests a driver has from a rider
  var matchesQuery =  "select \"riderFirstName\", \"riderLastName\", \"riderBiography\", \"riderID\", \"riderEndPointLat\", \"riderEndPointLong\", \"riderRouteUserID\", \"riderDays\", \"riderArrival\", \"riderDeparture\", \"riderRouteName\", \"riderRouteID\", \"matchID\", \"riderID\"  from  (select \"endPointLat\" as \"riderEndPointLat\", \"endPointLong\" as \"riderEndPointLong\", \"riderID\" as \"riderRouteUserID\", \"Days\" as \"riderDays\", \"arrivalTime\" as \"riderArrival\", \"departureTime\" as \"riderDeparture\", \"Name\" as \"riderRouteName\", \"routeID\" from carpool.\"Routes\") d JOIN  ((select * from carpool.\"Matches\" where \"riderID\" = 'XJKTmWm63iNCa3FGVSemwWezSYv1' AND \"Status\" = 'driverRequested') a JOIN (select \"firstName\" as \"riderFirstName\", \"lastName\" as \"riderLastName\", \"Biography\" as \"riderBiography\", \"userID\" from carpool.\"Users\")b  ON a.\"riderID\" = b.\"userID\")c  ON c.\"riderRouteID\" = d.\"routeID\"";
  db.query(matchesQuery, userID)
  .then(function(data) {
    console.log(data);
    res.send(data);
    });
  });



module.exports = router;
