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



router.get('/', function(req, res, next) {
var userID = req.query.userID;
db.one("select \"notificationLog\".\"notificationType\", \"notificationLog\".\"Date\", \"notificationLog\".\"Read\" from carpool.\"notificationLog\" where \"notificationLog\".\"userID\" = $1", userID)
.then(function(data) {
  console.log(data);
  res.status(200).json({
    status: 'Success',
    data: data,
    message:  'Retrieved Notifications.'
  });
})
  .catch(function(err){
    console.log(err);
  })
});



module.exports = router;
