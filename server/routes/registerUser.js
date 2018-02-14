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

router.post('/', function(req, res, next) {
 var userInfo = req.body.userInfo;
 var userJSON = JSON.parse(userInfo);
 var userID = userJSON['userID'];

 usersRef.update({
  [userID]: {
    lastName:  userJSON['lastName'],
    firstName: userJSON['firstName'],
    provider: userJSON['provider'],
    email: userJSON['email']
  }
});

  console.log ("User Set.");
});



module.exports = router;
