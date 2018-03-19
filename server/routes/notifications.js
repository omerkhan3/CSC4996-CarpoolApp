"use strict";

var express = require('express');
var router = express.Router();

const db = require('../routes/db');
const pgp = db.$config.pgp;


router.get('/', function(req, res, next) {
var userID = req.query.userID;
console.log(userID);
db.query("select \"notificationLog\".\"notificationType\", \"notificationLog\".\"Date\", \"notificationLog\".\"Read\" from carpool.\"notificationLog\" where \"notificationLog\".\"userID\" = $1", userID) // Query to view all notifications associated with a particular user.
.then(function(data) {
 console.log("Data:" , data);
 res.send(data);
});
});




module.exports = router;
