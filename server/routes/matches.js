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
var matchesQuery = " Select \"driverFirstName\", \"driverLastName\", \"driverBiography\", \"driverID\", \"driverEndPointLat\", \"driverEndPointLong\", \"driverRouteUserID\", \"driverArrival\", \"driverDeparture\", \"driverRouteName\", \"driverRouteID\", \"matchID\", \"riderID\"  FROM (select \"firstName\" as \"driverFirstName\", \"lastName\" as \"driverLastName\", \"Biography\" as \"driverBiography\", \"userID\" from carpool.\"Users\") g JOIN  ((select \"driverID\" as \"driverID2\", \"userID\" as \"driverUserID\" from carpool.\"Drivers\") f JOIN ((Select \"endPointLat\" as \"driverEndPointLat\", \"endPointLong\" as \"driverEndPointLong\", \"driverID\" as \"driverRouteUserID\", \"Days\" as \"driverDays\", \"arrivalTime\" as \"driverArrival\", \"departureTime\" as \"driverDeparture\", \"Name\" as \"driverRouteName\", \"routeID\" as \"driverRouteID2\" FROM carpool.\"driverRoute\") c JOIN ((Select * FROM carpool.\"Matches\") a JOIN (Select \"userID\", \"riderID\" as \"riderID2\" FROM carpool.\"Riders\" where \"userID\" = $1) b ON a.\"riderID\" = b.\"riderID2\") d ON c.\"driverRouteUserID\" = d.\"driverID\") e  ON e.\"driverID\" = f.\"driverID2\") h ON g.\"userID\" = h.\"driverUserID\"";
db.query(matchesQuery, userID)
.then(function(data) {
  console.log(data);
  res.send(data);
  });
});



module.exports = router;
