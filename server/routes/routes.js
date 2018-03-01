var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var firebase = require('firebase');
var admin = require('firebase-admin');
var router = express.Router();


router.post('/', function(req, res, next) {
 var routeInfo = req.body.routeInfo;
 var routeJSON = JSON.parse(routeInfo);
 var userID = routeJSON['userID'];
 console.log(routeJSON);

 if (routeJSON['Driver'] == true)
 {
   var driverID;
   var addDriverQuery = "INSERT INTO carpool.\"Drivers\"(\"userID\") values ('$1')";
   db.any(addDriverQuery, userID)
   .then(function () {
     console.log("Driver added.");
   })
   .catch(function (err) {
     console.log("Driver already exists.");
   });

   var getDriverIDQuery = "Select \"driverID\" from carpool.\"Drivers\" where \"userID\" = $1";
   db.any(getDriverIDQuery, userID)
   .then(function(data){
       console.log(data);
   })
   .catch(function(error){
       console.log('error:', error)
   });
   //console.log(driverID);
var test = routeJSON['Longitudes'][0];
console.log(test);
  var addDriverRouteQuery = "INSERT INTO carpool.\"driverRoute\"(\"driverID\", \"startTime\", \"endTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\") values($1, $2, $3, $4, $5, $6, $7)";
  db.any(addDriverRouteQuery, [
   14, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1]])
   .then(function () {
     console.log("Succesfully added route.");
     res.status(200)
       .json({
         status: 'Success',
         message: 'Driver Route Stored'
       });
   })
   .catch(function (err) {
     console.log(err);
     res.send(err);
   });

 }

});





module.exports = router;
