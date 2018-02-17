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


 // Attach an asynchronous callback to read the data at our posts reference
 db.ref('/Users/' + userID).once('value')
     .then( snapshot => {
      // res.send(snapshot.val());
      console.log (snapshot.val());
});


});



module.exports = router;
