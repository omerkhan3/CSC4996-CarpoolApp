var express = require('express');
var router = express.Router();


const db = require('../routes/db'); // configures our connection to the DB.
const pgp = db.$config.pgp;
const apnModule = require('../routes/apn'); // Allows us to connect to Apple Push Notification Service.
const apn = apnModule.apn;
const apnProvider = apnModule.apnProvider;

function sendPushNotification(message, deviceToken)
{
  let notification = new apn.Notification();
  notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600; // will expire in 24 hours from now
  notification.badge = 2;
  notification.sound = "ping.aiff";
  notification.alert = message;
  notification.payload = {'messageFrom': 'CarPool'};

  // Replace this with your app bundle ID:
  notification.topic = "com.CSC4996.CarpoolApp";

  apnProvider.send(notification, deviceToken).then( result => {
    // Sends a push notifications to the other party that their ride has been cancelled.
  // Show the result of the send operation:
     console.log(result);
  });
}


router.post('/', function(req, res, next) {
  var rideInfo = req.body.rideInfo;
  var rideJSON = JSON.parse(rideInfo);
  var otherID = rideJSON['otherID'];
  var matchID = rideJSON['matchID'];
  var date = rideJSON['Date'];

  if (rideJSON['liveRideType'] == "rideStarted") // Case for cancelling an individual ride.
  {
   // Date of the cancelled ride.

  db.query(`UPDATE carpool.\"scheduledRoutes\" SET \"Status\" = 'Started' where \"Date\" = '${date}' AND \"matchID\" = ${matchID}`)
  .then( function (){
    console.log(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${otherID}'`);
    db.one(`SELECT \"deviceToken\", \"firstName\" from carpool.\"Users\" where \"userID\" = '${otherID}'`)
    .then(function(result) {
      sendPushNotification(`Your driver ${result.firstName} is on their way!`, result.deviceToken);
    })
    .catch(function(error){
        console.log('Error Cancelling Ride:', error)
    });
    res.status(200)
      .json({
        status: 'Success',
        message: 'Ride Started'
      });

  })
  }

  else if (rideJSON['liveRideType'] == "riderPickedUp")
  {
    db.query(`UPDATE carpool.\"scheduledRoutes\" SET \"Status\" = 'riderPickedUp' where \"Date\" = '${date}' AND \"matchID\" = ${matchID}`)
    .then( function (){
      console.log(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${otherID}'`);
      db.one(`SELECT \"deviceToken\", \"firstName\" from carpool.\"Users\" where \"userID\" = '${otherID}'`)
      .then(function(result) {
        sendPushNotification(`You are on your way to your destination!`, result.deviceToken);
      })
      .catch(function(error){
          console.log('Error Cancelling Ride:', error)
      });
      res.status(200)
        .json({
          status: 'Success',
          message: 'Rider Picked Up.'
        });

    })
  }

  else
  {
    db.query(`UPDATE carpool.\"scheduledRoutes\" SET \"Status\" = 'riderDroppedOff' where \"Date\" = '${date}' AND \"matchID\" = ${matchID}`)
    .then( function (){
      console.log(`SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = '${otherID}'`);
      db.one(`SELECT \"deviceToken\", \"firstName\" from carpool.\"Users\" where \"userID\" = '${otherID}'`)
      .then(function(result) {
        sendPushNotification(`Thanks for riding with ${result.firstName}!`, result.deviceToken);
      })
      .catch(function(error){
          console.log('Error Cancelling Ride:', error)
      });
      res.status(200)
        .json({
          status: 'Success',
          message: 'Ride Concluded'
        });

    })
  }

});





module.exports = router;
