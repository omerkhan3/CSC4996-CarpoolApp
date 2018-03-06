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
     var addDriverRouteQuery = "INSERT INTO carpool.\"Routes\"(\"driverID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\", \"Matched\", \"Driver\") values($1, $2, $3, $4, $5, $6, $7, $8, $9, 'false', 'true')";
     db.any(addDriverRouteQuery, [userID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name'], routeJSON['Days']])
      .then(function () {
        console.log("Driver route added.");
        var setGeographyQuery = "UPDATE carpool.\"Routes\" SET startPoint = ST_POINT (\"startPointLat\", \"startPointLong\"), endPoint = ST_POINT (\"endPointLat\", \"endPointLong\")";
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

 else {
 var matchingQuery = "SELECT * FROM carpool.\"Routes\" WHERE ST_DWithin(startPoint, Geography(ST_MakePoint($1, $2)),4830) AND ST_DWithin(endPoint, Geography(ST_MakePoint($3, $4)),4830) AND (\"departureTime\" <= ($5) AND \"departureTime\" >= ($5  - interval '15 minutes')) AND (\"arrivalTime\" <= ($6 + interval '15 minutes') AND \"arrivalTime\" >= ($6)) AND \"Matched\" = 'false' AND \"Driver\" = 'true'";
     db.any(matchingQuery, [routeJSON['Latitudes'][0], routeJSON['Longitudes'][0], routeJSON['Latitudes'][1], routeJSON['Longitudes'][1], convertTo24Hour(routeJSON['departureTime']), convertTo24Hour(routeJSON['arrivalTime'])])
     .then(function(result) {
       if (result.length > 0){
            //console.log('Match Found: ', result);
            for (var key in result) {
              if (!result.hasOwnProperty(key)) continue;
              var obj = result[key];
              db.any("INSERT INTO carpool.\"Matches\"(\"riderID\", \"driverID\",  \"driverRouteID\", \"Status\") values($1, $2, $3, $4)",[userID, obj['driverID'], obj['routeID'], "Awaiting rider request."  ] )

}
           db.any("INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ($1, $2, $3, $4)", [userID, "Match", 'now', 'false']);
          }
       else {
          console.log("No match found.");
       }
     });
     var addRiderRouteQuery = "INSERT INTO carpool.\"Routes\"(\"riderID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\", \"Matched\", \"Driver\") values($1, $2, $3, $4, $5, $6, $7, $8, $9, 'false', 'false')";
    db.any(addRiderRouteQuery, [
      userID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name'], routeJSON['Days']])
      .then(function () {
        console.log("Succesfully added route.");
        var setGeographyQuery = "UPDATE carpool.\"Routes\" SET startPoint = ST_POINT (\"startPointLat\", \"startPointLong\"), endPoint = ST_POINT (\"endPointLat\", \"endPointLong\")";
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
