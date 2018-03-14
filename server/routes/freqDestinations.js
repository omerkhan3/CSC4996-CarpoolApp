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

router.post('/frequentDestinations/add', function(req, res, next) {
	var routeInfo = req.body.routeInfo;
	var routeJSON = JSON.parse(routeInfo);
	var userID = routeJSON['userID'];
	
	db.none("INSERT INTO carpool.\"frequentDestinations\"(\"userID\", \"homeAddress\", \"schoolAddress\", \"workAddress\", \"CustomAddress\", \"Custom\", \"Longitudes\", \"Latitudes\") values($1, $2, $3, $4, $5, $6, $7, $8)", [
	userID, routeJSON['home'], routeJSON['school'], routeJSON['work'], routeJSON['customAddress'], routeJSON['custom'], routeJSON['longitudes'][0], routeJSON['latitudes'][0]])
	.then(function() {
		res.status(200)
			.json({
				status: 'Success',
				message: 'Route info Stored'
			});
		})
		.catch(function(err) {
			res.send(err);
		});
	});
	
router.get('/frequentDestinations', function(req, res, next) {
	var userID = req.query.userID;
	console.log(userID);
	db.one("select \"frequentDestinations\".\"homeAddress\",\"frequentDestinations\".\"schoolAddress\",\"frequentDestinations\".\"workAddress\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Retrieved Route Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
	});

router.post('/frequentDestinations', function(req, res, next) {
	var routeInfo = req.body.routeInfo;
	var routeJSON = JSON.parse(routeInfo);
	console.log(routeJSON);
	var userID = routeJSON['userID'];
	var homeAddress = routeJSON['homeAddress'];
	var schoolAddress = routeJSON['schoolAddress'];
	var workAddress = routeJSON['workAddress'];
	var CustomAddress = routeJSON['CustomAddress'];
	var Custom = routeJSON['Custom'];
	var Longitudes = routeJSON['Longitudes'][0];
	var Latitudes = routeJSON['Latitudes'][0];
	console.log("Updating Frequent Destinations.");
	db.query("UPDATE carpool.\"frequentDestinations\" SET \"homeAddress\" = $1, \"schoolAddress\" = $2, \"workAddress\" = $3, \"CustomAddress\" = $4, \"Custom\" = $5, \"Latitudes\" = $6, \"Longitudes\" = $7 where \"userID\" = $8", [homeAddress, schoolAddress, workAddress, CustomAddress, Custom, Latitudes, Longitudes, userID])
	.then(function() {
		res.status(200)
			.json({
				status: 'Success',
				message: 'User Routes Updated.'
			});
		})
		.catch(function(err) {
			res.send(err);
		});
	});
	
module.exports = router;
	
