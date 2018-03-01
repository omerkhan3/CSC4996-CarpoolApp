var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var firebase = require('firebase');
var admin = require('firebase-admin');
var router = express.Router();

var promise = require('bluebird');
var options = {
  promiseLib: promise
};

var pgp = require('pg-promise')(options);
var conString = "postgres://carpool:carpool2018@carpool.clawh88zlo74.us-east-2.rds.amazonaws.com:5432/carpool";
var db = pgp(conString);


router.post('/register', function(req, res, next) {
 var userInfo = req.body.userInfo;
 var userJSON = JSON.parse(userInfo);
 var userID = userJSON['userID'];

 db.none("INSERT INTO carpool.\"Users\"(\"userID\", \"firstName\", \"lastName\", \"email\") values($1, $2, $3, $4)", [
   userID, userJSON['firstName'], userJSON['lastName'], userJSON['email']])
   .then(function () {
     res.status(200)
       .json({
         status: 'Success',
         message: 'User Info Stored'
       });
   })
   .catch(function (err) {
     res.send(error);
   });
});



router.get('/profile', function(req, res, next) {
var userID = req.query.userID;
console.log(userID);
db.one("select \"Users\".\"firstName\", \"Users\".\"lastName\", \"Users\".\"email\" from carpool.\"Users\" where \"Users\".\"userID\" = $1", userID)
.then(function(data) {
  console.log(data);
  res.status(200).json({
    status: 'Success',
    data: data,
    message:  'Retrieved User Profile.'
  });
})
  .catch(function(err){
    return next(err);
  });
});



module.exports = router;
