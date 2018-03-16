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
// Select all drivers the rider has matched with so they can request one.
var matchesQuery = "select distinct on (\"matchID\") * from (select \"firstName\" as \"riderFirstName\", \"lastName\" as \"riderLastName\", \"Biography\" as \"riderBiography\", \"userID\" from carpool.\"Users\")g JOIN ((select \"endPointLat\" as \"riderEndPointLat\", \"endPointLong\" as \"riderEndPointLong\", \"riderID\" as \"riderRouteUserID\", \"Days\" as \"riderDays\", \"arrivalTime\" as \"riderArrival\", \"departureTime\" as \"riderDeparture\", \"Name\" as \"riderRouteName\", \"routeID\" from carpool.\"Routes\")e JOIN ((select \"endPointLat\" as \"driverEndPointLat\", \"endPointLong\" as \"driverEndPointLong\",\"driverID\" as \"driverRouteUserID\",\"Days\" as \"driverDays\",\"arrivalTime\" as \"driverArrival\",\"departureTime\" as \"driverDeparture\",\"Name\" as \"driverRouteName\",\"routeID\" from carpool.\"Routes\") d  JOIN ((select * from carpool.\"Matches\" where (\"riderID\" = $1 AND \"Status\" = 'Awaiting rider request.') OR (\"driverID\" = $1 AND \"Status\" = 'driverRequested') ) a  JOIN (select \"firstName\" as \"driverFirstName\", \"lastName\" as \"driverLastName\",\"Biography\" as \"driverBiography\",\"userID\" from carpool.\"Users\")b  ON a.\"driverID\" = b.\"userID\")c  ON c.\"driverRouteID\" = d.\"routeID\")f ON e.\"riderRouteUserID\" = f.\"riderID\")h ON g.\"userID\" = h.\"riderID\"";
db.query(matchesQuery, userID)
.then(function(data) {
 console.log(data);
 res.send(data);
 });
});



module.exports = router;
