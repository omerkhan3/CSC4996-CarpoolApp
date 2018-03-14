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

router.post('/register', function(req, res, next) {
 var userInfo = req.body.userInfo;
 var userJSON = JSON.parse(userInfo);
 var userID = userJSON['userID'];

 db.none("INSERT INTO carpool.\"Users\"(\"userID\", \"firstName\", \"lastName\", \"Email\", \"Phone\", \"Biography\") values($1, $2, $3, $4, $5, $6)", [
   userID, userJSON['firstName'], userJSON['lastName'], userJSON['email'], userJSON['phone'], userJSON['biography']])
   .then(function () {
     res.status(200)
       .json({
         status: 'Success',
         message: 'User Info Stored'
       });
   })
   .catch(function (err) {
     res.send(err);
   });
});



router.get('/profile', function(req, res, next) {
var userID = req.query.userID;
console.log(userID);
db.one("select \"Users\".\"firstName\", \"Users\".\"lastName\", \"Users\".\"Email\", \"Users\".\"Phone\", \"Users\".\"Biography\" from carpool.\"Users\" where \"Users\".\"userID\" = $1", userID)
.then(function(data) {
  console.log(data);
  res.status(200).json({
    status: 'Success',
    data: data,
    message:  'Retrieved User Profile.'
  });
})
  .catch(function(err){
    console.log(err);
  })
});



router.post('/profile', function(req, res, next){
  var userInfo = req.body.userInfo;
  var userJSON = JSON.parse(userInfo);
  console.log(userJSON);
  var bio = userJSON['Biography'];
  var first = userJSON['firstName'];
  var last = userJSON['lastName'];
  var userID = userJSON['userID'];
  console.log("Updating Bio.");
  db.query("UPDATE carpool.\"Users\" SET \"Biography\" = $1, \"firstName\" = $2, \"lastName\" = $3 where \"userID\" = $4", [bio, first, last, userID])
    .then(function () {
      res.status(200)
        .json({
          status: 'Success',
          message: 'User Profile Updated.'
        });
    })
    .catch(function (err) {
      res.send(err);
    });
});



module.exports = router;
