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

function convertTo24Hour(time) {
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
     var addDriverRouteQuery = "INSERT INTO carpool.\"driverRoute\"(\"driverID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\") values($1, $2, $3, $4, $5, $6, $7, $8, $9)";
     db.any(addDriverRouteQuery, [data.driverID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name'], routeJSON['Days']])
      .then(function () {
        console.log("Succesfully added route.");
        res.status(200)
          .json({
            status: 'Success',
            message: 'Driver Route Stored'
          });
      })
      .catch(function (err) {
        console.log('error adding route:', err);
      });
   })
   .catch(function(error){
       console.log('error selecting driverID:', error)
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
 var matchingQuery = "SELECT * FROM carpool.\"driverRoute\" WHERE ST_DWithin(startPoint, Geography(ST_MakePoint($1, $2)),1000) AND ST_DWithin(endPoint, Geography(ST_MakePoint($3, $4)),1000) AND (\"departureTime\" <= ($5 + interval '15 minutes') AND \"departureTime\" >= ($5)) AND (\"arrivalTime\" <= ($6 + interval '15 minutes') AND \"arrivalTime\" >= ($6));";



   var riderID;
   var addRiderQuery = "INSERT INTO carpool.\"Riders\"(\"userID\") values ($1)";
   db.one(addRiderQuery, userID)
   .then(function () {
     console.log("Rider added.");
   })
   .catch(function (err) {
     console.log("Rider already exists.");
   });

   var getRiderIDQuery = "Select \"riderID\" from carpool.\"Riders\" where \"userID\" = $1";
   db.one(getRiderIDQuery, userID)
   .then(function(data){
     db.any(matchingQuery, [routeJSON['Latitudes'][0], routeJSON['Longitudes'][0], routeJSON['Latitudes'][1], routeJSON['Longitudes'][1], convertTo24Hour(routeJSON['departureTime']), convertTo24Hour(routeJSON['arrivalTime'])])
     .then(function(result) {
       if (result.length > 0){
            //console.log('Match Found: ', data);
            for (var key in result) {
              // skip loop if the property is from prototype
              if (!result.hasOwnProperty(key)) continue;
              var obj = result[key];
              db.any("INSERT INTO carpool.\"Matches\"(\"riderID\", \"driverID\",  \"driverRouteID\", \"Status\") values($1, $2, $3, $4)",[data.riderID, obj['driverID'], obj['routeID'], "Awaiting rider request."  ] )

}
            db.any("INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ($1, $2, $3, $4)", [userID, "Match", 'now', 'false']);
          //  db.any("INSERT INTO carpool.\"Matches\"(\"riderID\", \"driverID\",  \"driverRouteID\", \"Status\") values($1, $2, $3, $4, $5",[data.riderID, result.driverID, result.routeID, "Awaiting rider request."  ] )
          }
       else {
          console.log("No match found.");
       }
     });
     var addRiderRouteQuery = "INSERT INTO carpool.\"riderRoute\"(\"riderID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\") values($1, $2, $3, $4, $5, $6, $7, $8, $9)";
     db.any(addRiderRouteQuery, [
      data.riderID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name'], routeJSON['Days']])
      .then(function () {
        console.log("Succesfully added route.");
        res.status(200)
          .json({
            status: 'Success',
            message: 'Rider route stored.'
          });
      })
      .catch(function (err) {
        console.log('error adding route:', err);
      });
   })
   .catch(function(err){
       console.log('error getting riderID:', err)
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
