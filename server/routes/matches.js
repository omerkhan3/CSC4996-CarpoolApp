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


router.post('/approval', function(req, res, next) {
 var userInfo = req.body.userInfo;
 var userJSON = JSON.parse(userInfo);
 var userID = userJSON['userID'];

if (userJSON['reqeuestType'] == 'riderRequest')
{

  db.query("UPDATE carpool.\"Users\" SET \"Status\" = 'Driver Requested' where \"matchID\" = $1", [userJSON[matchID]])
   .then(function () {
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
   db.query("UPDATE carpool.\"Users\" SET \"Status\" = 'Matched' where \"matchID\" = $1", [userJSON[matchID]])
    .then(function () {
      db.query("UPDATE carpool.\"Routes\" SET \"Matched\" = 'true' where \"routeID\" = $1", [userJSON['driverRouteID']])
      .then(function() {
            db.query("UPDATE carpool.\"Routes\" SET \"Matched\" = 'true' where \"routeID\" = $1", [userJSON['riderRouteID']])
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

var matchesQuery = "select \"driverFirstName\", \"driverLastName\", \"driverBiography\", \"driverID\", \"driverEndPointLat\", \"driverEndPointLong\", \"driverRouteUserID\", \"driverDays\", \"driverArrival\", \"driverDeparture\", \"driverRouteName\", \"driverRouteID\", \"matchID\", \"riderID\" from (select \"endPointLat\" as \"driverEndPointLat\", \"endPointLong\" as \"driverEndPointLong\", \"driverID\" as \"driverRouteUserID\", \"Days\" as \"driverDays\", \"arrivalTime\" as \"driverArrival\", \"departureTime\" as \"driverDeparture\", \"Name\" as \"driverRouteName\", \"routeID\" from carpool.\"Routes\") d JOIN ((select * from carpool.\"Matches\" where \"riderID\" = $1) a JOIN (select \"firstName\" as \"driverFirstName\", \"lastName\" as \"driverLastName\", \"Biography\" as \"driverBiography\", \"userID\" from carpool.\"Users\")b ON a.\"driverID\" = b.\"userID\")c ON c.\"driverRouteID\" = d.\"routeID\"";
db.query(matchesQuery, userID)
.then(function(data) {
  console.log(data);
  res.send(data);
  });
});



module.exports = router;
