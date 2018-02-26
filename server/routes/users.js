var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var firebase = require('firebase');
var admin = require('firebase-admin');
var router = express.Router();
var pg = require('pg');
var db = admin.database();
var usersRef = db.ref('/Users');

var conString = "postgres://carpool:carpool2018@carpool.clawh88zlo74.us-east-2.rds.amazonaws.com:5432/carpool";
var client = new pg.Client(conString);

client.connect((err) => {
  if (err) {
    console.error('connection error', err.stack);
  } else {
    console.log('Connected to DB.');
  }
});



//var query = client.query("select \"Users\".\"firstName\", \"Users\".\"lastName\", \"Users\".\"email\" from carpool.\"Users\" where \"Users\".\"userID\" = 'OWVqu8jLXLSjizorl9FkgfUtoiq2';");





router.post('/register', function(req, res, next) {
 var userInfo = req.body.userInfo;
 var userJSON = JSON.parse(userInfo);
 var userID = userJSON['userID'];

/* usersRef.update({
  [userID]: {
    lastName:  userJSON['lastName'],
    firstName: userJSON['firstName'],
    provider: userJSON['provider'],
    email: userJSON['email']
  }
});
/*/

client.query("INSERT INTO carpool.\"Users\"(\"userID\", \"firstName\", \"lastName\", \"email\") values($1, $2, $3, $4)", [
  userID, userJSON['firstName'], userJSON['lastName'], userJSON['email']]);

  console.log ("User Set.");
});



router.get('/profile', function(req, res, next) {
var userID = req.query.userID;
console.log(userID);
//var profileRef = db.ref(`/Users/${userID}`);

/* profileRef.on('value', function(snapshot) {
   res.send(snapshot.val());
 }, function (errorObject) {
   res.send("The read failed: " + errorObject.code);
 });
/*/

client.query("select \"Users\".\"firstName\", \"Users\".\"lastName\", \"Users\".\"email\" from carpool.\"Users\" where \"Users\".\"userID\" = 'OWVqu8jLXLSjizorl9FkgfUtoiq2'")
  .then(result => res.send(result.rows))
  .catch(e => res.send(e.stack))


});



module.exports = router;
