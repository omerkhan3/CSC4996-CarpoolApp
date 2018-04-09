var express = require('express');
var router = express.Router();
const db = require('../routes/db');
const pgp = db.$config.pgp;

router.get('/getDestination', function(req, res, next) {
	var userID = req.query.userID;
	//var destination
	console.log(userID);
	db.query("select \"frequentDestinations\".\"Name\", \"frequentDestinations\".\"Address\" from carpool.\"frequentDestinations\" where \"frequentDestinations\".\"userID\" = $1", userID)
.then(function(data) {
  console.log(data);
  res.send(data);
  });
});


router.post('/saveDestination', function(req, res, next) {
	var destinationInfo = req.body.destinationInfo;
	var destinationJSON = JSON.parse(destinationInfo);
	console.log(destinationJSON);
	var destinationsLengthJSON = destinationJSON.length;
	console.log("Number of Destinations JSON", destinationsLengthJSON);

	for (var l = 0; l < destinationsLengthJSON; l++ )
	{
		var name =  destinationJSON[l]['Name'];
		var userID = destinationJSON[l]['userID'];
		var address = destinationJSON[l]['Address'];
    console.log("Element", l, name , destinationJSON[l]['Address'] );
		db.none(`INSERT INTO carpool.\"frequentDestinations\"(\"userID\", \"Name\", \"Address\") VALUES ('${userID}', '${name}', '${address}') ON CONFLICT (\"userID\", \"Name\") DO UPDATE SET \"Name\" = '${name}', \"Address\" = '${address}'`)
		.catch(function(err) {
			console.log(err);
		})
	}
	res.status(200).json({
		status: 'Success',
		message: 'Destinations Stored.'
	});
});


module.exports = router;
