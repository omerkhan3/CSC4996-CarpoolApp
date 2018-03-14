"use strict";

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


const apn = require('apn');

let options = {
   token: {
     key: "cert_notifications.p8",
    // Replace keyID and teamID with the values you've previously saved.
     keyId: "3KL4446N4D",
     teamId: "3Z83W2KF98"
  },
   production: false
 };

 let apnProvider = new apn.Provider(options);

 // Replace deviceToken with your particular token:
 let deviceToken = "2E008C45EBC2562C1C0F0467294C10C794D11CBB98F4CDF5D2C9185BF33A8C3F";

// Prepare the notifications
let notification = new apn.Notification();
 notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600; // will expire in 24 hours from now
notification.badge = 2;
notification.sound = "ping.aiff";
notification.alert = "Hello from Omer";
notification.payload = {'messageFrom': 'Notifications are working!'};

 // Replace this with your app bundle ID:
 notification.topic = "com.CSC4996.CarpoolApp";

 // Send the actual notification
apnProvider.send(notification, deviceToken).then( result => {
// Show the result of the send operation:
 	console.log(result);
});


 // Close the server
apnProvider.shutdown();



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
