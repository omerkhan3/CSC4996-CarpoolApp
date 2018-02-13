var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var firebase = require('firebase');
var admin = require('firebase-admin');
var router = express.Router();
var serviceAccount = require('../csc4996-carpoolapp-firebase-adminsdk-fsifh-456e34f4e0.json');

admin.initializeApp({
 credential: admin.credential.cert(serviceAccount),
 databaseURL: 'https://csc4996-carpoolapp.firebaseio.com'
});


router.post('/', function(req, res, next) {
 var registrationID = req.body.uniqueID;
  //var userInfo = req.body.userInfo;



  console.log (registrationID);
//  console.log(userInfo);
  console.log ("connection received.");
});

/*
var db = admin.database();
var ref = db.ref('/');
var usersRef = ref.child("Users");
usersRef.update({
	nodetest2: {
		first_name:  "Test",
		last_name: "Khan"
	}
});

console.log ("wrote to db.");/*/
module.exports = router;
