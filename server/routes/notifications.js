 var express = require('express');
var router = express.Router();

const db = require('../routes/db'); // configures connection to the DB.
const pgp = db.$config.pgp;


// This GET request sends all notifications associated with the passed userID.
router.get('/', function(req, res, next) {
var userID = req.query.userID;
console.log(userID);
db.query(`select \"notificationLog\".\"notificationType\", \"notificationLog\".\"Date\", \"notificationLog\".\"Read\", \"notificationLog\".\"notificationID\" from carpool.\"notificationLog\" where \"notificationLog\".\"userID\" = '${userID}' ORDER BY \"Date\" desc`) // Query to view all notifications associated with a particular user.
.then(function(data) {
  db.query(`UPDATE carpool.\"notificationLog\" SET \"Read\" = 'true' where \"userID\" = '${userID}'`)
  .then(function(){
    res.send(data);
  })
  .catch(function(error){
      console.log('Error updating notifications to read: ', error)
  });
})
.catch(function(error){
    console.log('Error updating notifications to read: ', error)
});
});

router.post('/deleteIndividual', function(req, res, next) {
	var deletingNotification = req.body.deletingNotification;
	var deleteNotificationJSON = JSON.parse(deletingNotification);
	console.log(deleteNotificationJSON);
		db.none(`DELETE from carpool.\"notificationLog\" where \"notificationID\" = ${deleteNotificationJSON['notificationID']}`)
		.then(function() {
			res.status(200).json({
				status: 'Success',
				message: 'Notification deleted.'
			})
		})
		.catch(function(err) {
			console.log(err);
		})

});



module.exports = router;
