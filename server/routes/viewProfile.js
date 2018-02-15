var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var firebase = require('firebase');
var admin = require('firebase-admin');
var router = express.Router();

var db = admin.database();
var usersRef = db.ref('/Users');

router.get('/', function(req, res, next) {
 var userID = req.body.userID;


 // Attach an asynchronous callback to read the data at our posts reference
 ref.on(userID, function(snapshot) {
   console.log(snapshot.val());
 }, function (errorObject) {
   console.log("The read failed: " + errorObject.code);
 });


});



module.exports = router;
