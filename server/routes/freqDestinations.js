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

//router.post('/frequentDestinations/add', function(req, res, next) {
//	var routeInfo = req.body.routeInfo;
//	var routeJSON = JSON.parse(routeInfo);
//	var userID = routeJSON['userID'];
//	console.log(routeJSON)
//	db.none("INSERT INTO carpool.\"frequentDestinations\"(\"userID\", \"Name\", \"Address\") values($1, $2, $3)", [
//	userID, routeJSON['name'], routeJSON['address']])
//	console.log("Inserting values.")
//	.then(function() {
//		res.status(200)
//			.json({
//				status: 'Success',
//				message: 'Route info Stored'
//			});
//		})
//		.catch(function(err) {
//			res.send(err);
//		});
//	});

//router.get('/frequentDestinations', function(req, res, next) {
//	var userID = req.query.userID;
//	console.log(userID);
//	db.one("select \"frequentDestinations\".\"Address\",\"frequentDestinations\".\"workAddress\",\"frequentDestinations\".\"schoolAddress\",\"frequentDestinations\".\"otherAddress\",\"frequentDestinations\".\"Name4\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
//	.then(function(data) {
//		console.log(data);
//		res.status(200).json({
//			status: 'Success',
//			data: data,
//			message: 'Retrieved Route Info.'
//		});
//	})
//		.catch(function(err) {
//			console.log(err);
//		})
//	});

router.get('/homeDestination', function(req, res, next) {
	var userID = req.query.userID;
	console.log(userID);
	db.one("select \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
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
	db.one("select \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
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
	db.one("select \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
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
	db.one("select \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
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

router.post('/homeDestination', function(req, res, next) {
	var homeInfo = req.body.homeInfo;
	var homeJSON = JSON.parse(homeInfo);
	console.log(homeJSON);
	var userID = homeJSON['userID'];
	var name = homeJSON['Name'];
	var address = homeJSON['Address'];
	var longitudes = homeJSON['Longitudes'][0];
	var latitudes = homeJSON['Latitudes'][0];
	
	if (name == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Name\") values($1)", [userID, homeJSON['name']])
	}
	if (address == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Address\") values($1)", [userID, homeJSON['address']])
	}
	if (latitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Latitudes\") values($1)", [userID, homeJSON['latitudes'][0]])
	}
	if (longitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Longitudes\") values($1)", [userID, homeJSON['longitudes'][0]])
	}
	if (name != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Name\" = $1 where \"userID\" = $2", [name, userID])
	}
	else (address != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Address\" = $1 where \"userID\" = $2", [address, userID])
	}
	if (latitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Latitudes\" = $1 where \"userID\" = $2", [latitudes, userID])
	}
	else (longitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Longitudes\" = $1 where \"userID\" = $2", [longitudes, userID])
	}
	
	console.log("Updating Home Destinations.")
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Updated Home Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
});
	
router.post('/schoolDestination', function(req, res, next) {
	var schoolInfo = req.body.schoolInfo;
	var schoolJSON = JSON.parse(schoolInfo);
	console.log(schoolJSON);
	var userID = schoolJSON['userID'];
	var name = schoolJSON['Name'];
	var address = schoolJSON['Address'];
	var longitudes = schoolJSON['Longitudes'][0];
	var latitudes = schoolJSON['Latitudes'][0];
	
	if (name == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Name\") values($1)", [userID, schoolJSON['name']])
	}
	if (address == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Address\") values($1)", [userID, schoolJSON['address']])
	}
	if (latitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Latitudes\") values($1)", [userID, schoolJSON['latitudes'][0]])
	}
	if (longitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Longitudes\") values($1)", [userID, schoolJSON['longitudes'][0]])
	}
	if (name != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Name\" = $1 where \"userID\" = $2", [name, userID])
	}
	else (address != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Address\" = $1 where \"userID\" = $2", [address, userID])
	}
	if (latitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Latitudes\" = $1 where \"userID\" = $2", [latitudes, userID])
	}
	else (longitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Longitudes\" = $1 where \"userID\" = $2", [longitudes, userID])
	}
	console.log("Updating School Destinations.")
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Updated School Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
});

router.post('/workDestination', function(req, res, next) {
	var workInfo = req.body.workInfo;
	var workJSON = JSON.parse(workInfo);
	console.log(workJSON);
	var userID = workJSON['userID'];
	var name = workJSON['Name'];
	var address = workJSON['Address'];
	var longitudes = workJSON['Longitudes'][0];
	var latitudes = workJSON['Latitudes'][0];
	
	if (name == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Name\") values($1)", [userID, workJSON['name']])
	}
	if (address == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Address\") values($1)", [userID, workJSON['address']])
	}
	if (latitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Latitudes\") values($1)", [userID, workJSON['latitudes'][0]])
	}
	if (longitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Longitudes\") values($1)", [userID, workJSON['longitudes'][0]])
	}
	if (name != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Name\" = $1 where \"userID\" = $2", [name, userID])
	}
	else (address != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Address\" = $1 where \"userID\" = $2", [address, userID])
	}
	if (latitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Latitudes\" = $1 where \"userID\" = $2", [latitudes, userID])
	}
	else (longitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Longitudes\" = $1 where \"userID\" = $2", [longitudes, userID])
	}
	console.log("Updating Work Destinations.")
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Updated Work Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
});

router.post('/customDestination', function(req, res, next) {
	var customInfo = req.body.customInfo;
	var customJSON = JSON.parse(customInfo);
	console.log(customJSON);
	var userID = customJSON['userID'];
	var name = customJSON['Name'];
	var address = customJSON['Address'];
	var longitudes = customJSON['Longitudes'][0];
	var latitudes = customJSON['Latitudes'][0];
	
	if (name == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Name\") values($1)", [userID, customJSON['name']])
	}
	if (address == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Address\") values($1)", [userID, customJSON['address']])
	}
	if (latitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Latitudes\") values($1)", [userID, customJSON['latitudes'][0]])
	}
	if (longitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Longitudes\") values($1)", [userID, customJSON['longitudes'][0]])
	}
	if (name != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Name\" = $1 where \"userID\" = $2", [name, userID])
	}
	else (address != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Address\" = $1 where \"userID\" = $2", [address, userID])
	}
	if (latitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Latitudes\" = $1 where \"userID\" = $2", [latitudes, userID])
	}
	else (longitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Longitudes\" = $1 where \"userID\" = $2", [longitudes, userID])
	}
	console.log("Updating Custom Destinations.")
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Updated Custom Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
});
	
//router.post('/frequentDestinations', function(req, res, next) {
//	var routeInfo = req.body.routeInfo;
//	var routeJSON = JSON.parse(routeInfo);
//	console.log(routeJSON);
//	var userID = routeJSON['userID'];
//	var name = routeJSON['Name'];
//	var name2 = routeJSON['Name2']
//	var name3 = routeJSON['Name3']
//	var name4 = routeJSON['Name4'];
//	var Address = routeJSON['Address'];
//	var school = routeJSON['schoolAddress'];
//	var work = routeJSON['workAddress'];
//	var otherAddress = routeJSON['otherAddress'];
//	var longitudes = routeJSON['Longitudes'][0];
//	var latitudes = routeJSON['Latitudes'][0];

//	if (Address == null)
//	{
//		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Address\") values($1)", [userID, routeJSON['address']])
//	}
//	if (work == null)
//	{
//		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"workAddress\") values($1)", [userID, routeJSON['workaddress']])
//	}
//	if (school == null)
//	{
//		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"schoolAddress\") values($1)", [userID, routeJSON['schooladdress']])
//	}
//	if (name4 == null)
//	{
//		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Name4\") values($1)", [userID, routeJSON['name4']])
//	}
//	if (otherAddress == null)
//	{
//		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"otherAddress\") values($1)", [userID, routeJSON['otheraddress']])
//	}
//	if (latitudes == null)
//	{
//		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Latitudes\") values($1)", [userID, routeJSON['latitudes'][0]])
//	}
//	if (longitudes == null)
//	{
//		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Longitudes\") values($1)", [userID, routeJSON['longitudes'][0]])
//	}
//	else (Address != null)
//	{
//		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Address\" = $1 where \"userID\" = $2", [Address, userID])
//	}
//	if (school != null)
//	{
//		db.query("UPDATE carpool.\"frequentDestinations\" SET \"schoolAddress\" = $1 where \"userID\" = $2", [school, userID])
//	}
//	else (work != null)
//	{
//		db.query("UPDATE carpool.\"frequentDestinations\" SET \"workAddress\" = $1 where \"userID\" = $2", [work, userID])
//	}
//	if (otherAddress != null)
//	{
//		db.query("UPDATE carpool.\"frequentDestinations\" SET \"otherAddress\" = $1 where \"userID\" = $2", [otherAddress, userID])
//	}
//	else (longitudes != null)
//	{
//		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Longitudes\" = $1 where \"userID\" = $2", [longitudes, userID])
//	}
//	if (latitudes != null)
//	{
//		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Latitudes\" = $1 where \"userID\" = $2", [latitudes, userID])
//	}
//	else (name4 != null)
//	{
//		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Name4\" = $1 where \"userID\" = $2", [name4, userID])
//	}
//	console.log("Updating Frequent Destinations.")
//	.then(function(data) {
//		console.log(data);
//		res.status(200).json({
//			status: 'Success',
//			data: data,
//			message: 'Updated Route Info.'
//		});
//	})
//		.catch(function(err) {
//			console.log(err);
//		})
//});

module.exports = router;
