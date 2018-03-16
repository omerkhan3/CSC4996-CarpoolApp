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
	console.log(routeJSON)
	db.none("INSERT INTO carpool.\"frequentDestinations\"(\"userID\", \"Name\", \"Address\") values($1, $2, $3)", [
	userID, routeJSON['name'], routeJSON['address']])
	console.log("Inserting values.")
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
	db.one("select \"frequentDestinations\".\"Address\",\"frequentDestinations\".\"workAddress\",\"frequentDestinations\".\"schoolAddress\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
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
	var Name = routeJSON['Name'];
	var Address = routeJSON['Address'];
	var school = routeJSON['schoolAddress'];
	var work = routeJSON['workAddress'];
	var longitudes = routeJSON['Longitudes'][0];
	var latitudes = routeJSON['Latitudes'][0];
	//console.log("Updating Frequent Destinations.");
	
	//if (Name == null)
	//{
	//	db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Name\") values($1)", [userID, routeJSON['name']])
	//}
	if (Address == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Address\") values($1)", [userID, routeJSON['address']])
	}
	if (work == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"workAddress\") values($1)", [userID, routeJSON['workaddress']])	
	}
	if (school == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"schoolAddress\") values($1)", [userID, routeJSON['schooladdress']])
	}
	if (latitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Latitudes\") values($1)", [userID, routeJSON['latitudes'][0]])
	}
	if (longitudes == null)
	{
		db.none("INSERT INTO carpool.\"frequentDestinations\"(\"Longitudes\") values($1)", [userID, routeJSON['longitudes'][0]])
	}
	//else if (Name != null) 
	//{
	//	db.query("UPDATE carpool.\"frequentDestinations\" SET \"Name\" = $1 where \"userID\" = $2", [Name, userID])
	//}
	else (Address != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Address\" = $1 where \"userID\" = $2", [Address, userID])
	}
	if (school != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"schoolAddress\" = $1 where \"userID\" = $2", [school, userID])
	}
	else (work != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"workAddress\" = $1 where \"userID\" = $2", [work, userID])
	}
	if (longitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Longitudes\" = $1 where \"userID\" = $2", [longitudes, userID])
	}
	else (latitudes != null)
	{
		db.query("UPDATE carpool.\"frequentDestinations\" SET \"Latitudes\" = $1 where \"userID\" = $2", [latitudes, userID])
	}
	console.log("Updating Frequent Destinations.")
	.then(function(data) {
		console.log(data);
		res.status(200).json({
			status: 'Success',
			data: data,
			message: 'Updated Route Info.'
		});
	})
		.catch(function(err) {
			console.log(err);
		})
});
	
module.exports = router;