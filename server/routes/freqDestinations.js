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



router.get('/homeDestination', function(req, res, next) {
	var userID = req.query.userID;
	console.log(userID);
	db.query("select \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Retrieved Home Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
	});
router.get('/schoolDestination', function(req, res, next) {
	var userID = req.query.userID;
	console.log(userID);
	db.query("select \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Retrieved Home Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
	});
router.get('/workDestination', function(req, res, next) {
	var userID = req.query.userID;
	console.log(userID);
	db.query("select \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Retrieved Home Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
	});
router.get('/customDestination', function(req, res, next) {
	var userID = req.query.userID;
	console.log(userID);
	db.query("select \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Retrieved Home Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
	});


router.post('/saveDestination', function(req, res, next) {
	var destinationInfo = req.body.destinationInfo;
	var destinationJSON = JSON.parse(destinationInfo);
	console.log(destinationJSON);
	var destinationsLengthJSON = destinationJSON.length;
	console.log("Number of Destinations JSON", destinationsLengthJSON);

	for (var l = 0; l < destinationsLengthJSON; l++ )
	{
		var name =  destinationJSON[l]['Name'];
		var userID = destinationJSON[l]['userID'];
		var address = destinationJSON[l]['Address'];
    console.log("Element", l, name , destinationJSON[l]['Address'] );
		db.none(`INSERT INTO carpool.\"frequentDestinations\"(\"userID\", \"Name\", \"Address\") VALUES ('${userID}', '${name}', '${address}') ON CONFLICT (\"userID\", \"Name\") DO UPDATE SET \"Name\" = '${name}', \"Address\" = '${address}'`)
		.catch(function(err) {
			console.log(err);
		})
	}
	res.status(200).json({
		status: 'Success',
		message: 'Destinations Stored.'
	});
});


module.exports = router;
