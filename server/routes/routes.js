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

router.post('/', function(req, res, next) {
 var routeInfo = req.body.routeInfo;
 var routeJSON = JSON.parse(routeInfo);
 var userID = routeJSON['userID'];
 console.log(routeJSON);

 if (routeJSON['Driver'] == true)
 {
   var driverID;
   var addDriverQuery = "INSERT INTO carpool.\"Drivers\"(\"userID\") values ($1)";
   db.one(addDriverQuery, userID)
   .then(function () {
     console.log("Driver added.");
   })
   .catch(function (err) {
     console.log("Driver already exists.");
   });

   var getDriverIDQuery = "Select \"driverID\" from carpool.\"Drivers\" where \"userID\" = $1";
   db.one(getDriverIDQuery, userID)
   .then(function(data){
       driverID = data.driverID;
   })
   .catch(function(error){
       console.log('error:', error)
   });


  var addDriverRouteQuery = "INSERT INTO carpool.\"driverRoute\"(\"driverID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\") values($1, $2, $3, $4, $5, $6, $7, $8)";
  db.any(addDriverRouteQuery, [
   driverID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name']])
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

   var setGeographyQuery = "UPDATE carpool.\"driverRoute\" SET startPoint = ST_POINT (\"startPointLat\", \"startPointLong\"); UPDATE carpool.\"driverRoute\" SET endPoint = ST_POINT (\"endPointLat\", \"endPointLong\")";
   db.none(setGeographyQuery)
   .then(function () {
     console.log("Geographies Set.");
   })
   .catch(function(err) {
     console.log("Error");
   })

 }

 else {

 var matchingQuery = "SELECT * FROM carpool.\"driverRoute\" WHERE ST_DWithin(startPoint, Geography(ST_MakePoint($1, $2)),1000) AND ST_DWithin(endPoint, Geography(ST_MakePoint($3, $4)),1000) AND \"departureTime\" = $5 AND \"arrivalTime\" = $6;";
 db.any(matchingQuery, [routeJSON['Latitudes'][0], routeJSON['Longitudes'][0], routeJSON['Latitudes'][1], routeJSON['Longitudes'][1], routeJSON['departureTime'], routeJSON['arrivalTime']])
 .then(function(data) {
   console.log(data);
 })

   var riderID;
   var addRiderQuery = "INSERT INTO carpool.\"Riders\"(\"userID\") values ($1)";
   db.one(addRiderQuery, userID)
   .then(function () {
     console.log("Rider added.");
   })
   .catch(function (err) {
     console.log(err);
   });

   var getRiderIDQuery = "Select \"riderID\" from carpool.\"Riders\" where \"userID\" = $1";
   db.one(getRiderIDQuery, userID)
   .then(function(data){
       riderID = data.riderID;
   })
   .catch(function(error){
       console.log('error:', error)
   });


   var addDriverRouteQuery = "INSERT INTO carpool.\"riderRoute\"(\"riderID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\") values($1, $2, $3, $4, $5, $6, $7, $8)";
   db.any(addDriverRouteQuery, [
    riderID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name']])
    .then(function () {
      console.log("Succesfully added route.");
      res.status(200)
        .json({
          status: 'Success',
          message: 'Rider route stored.'
        });
    })
    .catch(function (err) {
      console.log(err);
      res.send(err);
    });

    var setGeographyQuery = "UPDATE carpool.\"riderRoute\" SET startPoint = ST_POINT (\"startPointLat\", \"startPointLong\"); UPDATE carpool.\"riderRoute\" SET endPoint = ST_POINT (\"endPointLat\", \"endPointLong\")";
    db.none(setGeographyQuery)
    .then(function () {
      console.log("Geographies Set.");
    })
    .catch(function(err) {
      console.log("Error");
    })


 }

});





module.exports = router;
