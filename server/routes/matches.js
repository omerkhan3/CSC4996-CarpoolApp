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



router.get('/', function(req, res, next) {
var userID = req.query.userID;

var matchesQuery = "Select \"driverFirstName\", \"driverLastName\", \"driverBiography\", \"driverID\", \"driverEndPointLat\", \"driverEndPointLong\", \"driverRouteUserID\", \"driverDays\", \"driverArrival\", \"driverDeparture\", \"driverRouteName\", \"driverRouteID\", \"matchID\", \"riderID\" from (Select \"firstName\" as \"driverFirstName\", \"lastName\" as \"driverLastName\", \"Biography\" as \"driverBiography\", \"driverID\" as \"driverID2\" from carpool.\"Users\") f JOIN ((Select \"endPointLat\" as \"driverEndPointLat\", \"endPointLong\" as \"driverEndPointLong\", \"driverID\" as \"driverRouteUserID\", \"Days\" as \"driverDays\", \"arrivalTime\" as \"driverArrival\", \"departureTime\" as \"driverDeparture\", \"Name\" as \"driverRouteName\", \"routeID\" as \"driverRouteID2\" from carpool.\"Routes\" where \"Driver\" = 'true') d JOIN ((select * from carpool.\"Matches\") a JOIN (select \"userID\", \"riderID\" as \"riderID2\" from carpool.\"Users\" where \"userID\" = $1)b ON a.\"riderID\" = b.\"riderID2\")c ON c.\"driverRouteID\" = d.\"driverRouteID2\") e ON e.\"driverID\" = f.\"driverID2\"";
db.query(matchesQuery, userID)
.then(function(data) {
  console.log(data);
  res.send(data);
  });
});



module.exports = router;
