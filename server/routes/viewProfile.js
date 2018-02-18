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
var userID = req.query.userID;
console.log(userID);
var profileRef = db.ref(`/Users/${userID}`);

 profileRef.on('value', function(snapshot) {
   res.send(snapshot.val());
 }, function (errorObject) {
   res.send("The read failed: " + errorObject.code);
 });



});



module.exports = router;
