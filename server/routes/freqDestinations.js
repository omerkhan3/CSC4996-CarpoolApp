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

router.post('/frequentDestinations', function(req, res, next) {
	var routeInfo = req.body.routeInfo;
	var routeJSON = JSON.parse(routeInfo);
	var userID = routeJSON['userID'];
	
	db.one("INSERT INTO carpool.\"Users\"(\"userID\", \"homeAddress\", \"schoolAddress\", \"workAddress\") values($1, $2, $3, $4)", [
	userID, routeJSON['homeAddress'], routeJSON['schoolAddress'], routeJSON['workAddress']])
	.then(function() {
		res.status(200)
			.json({
				status: 'Success',
				message: "Route info Stored'
			});
		})
		.catch(function(err) {
			res.send(err);
		});
	});


router.post('/frequentDestinations', function(req, res, next) {
	var routeInfo = req.body.routeInfo;
	var routeJSON = JSON.parse(routeInfo);
	console.log(routeJSON);
	var userID = routeJSON['userID'];
	var homeAddress = routeJSON['homeAddress'];
	var schoolAddress = routeJSON['schoolAddress'];
	var workAddress = routeJSON['workAddress'];
	console.log("Updating Frequent Destinations.");
	db.query("UPDATE carpool.\"Users\" SET \"homeAddress\" = $1, \"schoolAddress\" = $2, \"workAddress\" = $3 where \"userID\" = $4", [homeAddress, schoolAddress, workAddress, userID])
	.then(function() {
		res.status(200)
			.json({
				status: 'Success'
				message: 'User Routes Updated.'
			});
		})
		.catch(function(err) {
			res.send(err);
		});
	});
	
module.exports = router;
	
