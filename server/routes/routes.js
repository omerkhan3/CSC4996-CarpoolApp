var express = require('express');
var router = express.Router();

const db = require('../routes/db');
const pgp = db.$config.pgp;
const apnModule = require('../routes/apn');
const apn = apnModule.apn;
const apnProvider = apnModule.apnProvider;

var distance = require('google-distance');

function convertTo24Hour(time) { // concert to military time, we will eventually do this client-side.
    time = time.toUpperCase();
    var hours = parseInt(time.substr(0, 2));
    if(time.indexOf('AM') != -1 && hours == 12) {
        time = time.replace('12', '0');
    }
    if(time.indexOf('PM')  != -1 && hours < 12) {
        time = time.replace(hours, (hours + 12));
    }
    var time = time.replace(/( AM| PM)/, '');
    return (time + ':00');
}



router.get('/', function(req, res, next) {
var userID = req.query.userID;
db.query("select \"driverStartPointLat\", \"driverStartPointLong\", \"driverEndPointLat\", \"driverEndPointLong\", \"riderStartPointLat\", \"riderStartPointLong\", \"riderEndPointLat\", \"riderEndPointLong\", \"matchID\", \"Day\", \"Date\", \"driverRouteID\", \"riderRouteID\", \"riderID\", \"driverID\", \"riderPickupTime\", \"riderDropOffTime\", \"driverLeaveTime\", \"riderPickupTime2\"from (select \"startPointLat\" as \"driverStartPointLat\",  \"startPointLong\" as \"driverStartPointLong\", \"endPointLat\" as \"driverEndPointLat\",  \"endPointLong\" as \"driverEndPointLong\", routeID\" from carpool.\"Routes\")e JOIN ((select \"startPointLat\" as \"riderStartPointLat\",  \"startPointLong\" as \"riderStartPointLong\", \"endPointLat\" as \"riderEndPointLat\",  \"endPointLong\" as \"riderEndPointLong\", \"routeID\" from carpool.\"Routes\") c JOIN ((select \"Day\", \"Date\", \"Status\", \"matchID\" as \"scheduledRideMatchID\" from carpool.\"scheduledRoutes\" where \"Date\" >= 'now' and \"Status\" = 'Scheduled') a JOIN (select * from carpool.\"Matches\" where (\"riderID\" = $1 OR \"driverID\" = $1) AND \"Status\" = 'Matched') b ON a.\"scheduledRideMatchID\" = b.\"matchID\")d ON d.\"riderRouteID\" = c.\"routeID\")f ON f.\"driverRouteID\" = e.\"routeID\" ORDER BY \"Date\" Limit 10", [userID])
.then(function(data) {
 res.send(data);
});


});


router.post('/', function(req, res, next) {
 var routeInfo = req.body.routeInfo;
 var routeJSON = JSON.parse(routeInfo);
 var userID = routeJSON['userID'];
 console.log(routeJSON);


 if (routeJSON['Driver'] == true) // if user marked "Driver" as true.
  {
     var addDriverRouteQuery = "INSERT INTO carpool.\"Routes\"(\"driverID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\", \"Matched\", \"Driver\") values($1, $2, $3, $4, $5, $6, $7, $8, $9, 'false', 'true')"; // this is the query to add driver's route.
     db.any(addDriverRouteQuery, [userID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name'], routeJSON['Days']])
      .then(function () {
        console.log("Driver route added.");
        var setGeographyQuery = "UPDATE carpool.\"Routes\" SET startPoint = ST_POINT (\"startPointLat\", \"startPointLong\"), endPoint = ST_POINT (\"endPointLat\", \"endPointLong\")"; // Set geography object based on coordinates added by user.
        db.none(setGeographyQuery)
        .then(function () {
          console.log("Geographies Set.");
        });
        res.status(200)
          .json({
            status: 'Success',
            message: 'Driver Route Stored'
          });
      })
   .catch(function(error){
       console.log('error selecting driverID:', error)
   });



 }

 else {
   console.log('test');
 var matchingQuery = "SELECT * FROM carpool.\"Routes\" WHERE ST_DWithin(startPoint, Geography(ST_MakePoint($1, $2)),4830) AND ST_DWithin(endPoint, Geography(ST_MakePoint($3, $4)),4830) AND (\"departureTime\" <= ($5) AND \"departureTime\" >= ($5  - interval '15 minutes')) AND (\"arrivalTime\" <= ($6 + interval '15 minutes') AND \"arrivalTime\" >= ($6)) AND \"Matched\" = 'false' AND \"Driver\" = 'true'"; // Query to find all drivers whose routes are within a 3 mile radius of start and endpoint, and within 15 minute time interval of arrival and departure.
     db.any(matchingQuery, [routeJSON['Latitudes'][0], routeJSON['Longitudes'][0], routeJSON['Latitudes'][1], routeJSON['Longitudes'][1], convertTo24Hour(routeJSON['departureTime']), convertTo24Hour(routeJSON['arrivalTime'])])
     .then(function(result) {
       if (result.length > 0){
            //console.log('Match Found: ', result);
            for (var key in result) {
              if (!result.hasOwnProperty(key))
                continue; // traverse through result.
              else{
              var obj = result[key];
              var leg1, leg2, leg3;
              getFirstLeg();

              function getFirstLeg()
              {
              distance.get({
                  origin: `${obj['startPointLat']}, ${obj['startPointLong']}`,
                  destination: `${routeJSON['Latitudes'][0]}, ${routeJSON['Longitudes'][0]}`,
                },
                function(err, data) {
                    if (err) return console.log(err);
                    leg1 = data.duration;
                    getSecondLeg(leg1);
                  });
                }
            function getSecondLeg(leg1){
              distance.get({
                  origin: `${routeJSON['Latitudes'][0]}, ${routeJSON['Longitudes'][0]}`,
                  destination: `${routeJSON['Latitudes'][1]}, ${routeJSON['Longitudes'][1]}`,
                    },
                    function(err, data) {
                        if (err) return console.log(err);
                        leg2 = data.duration;
                        getThirdLeg(leg1, leg2);
                      });
                    }

                    function getThirdLeg(leg1, leg2){
                      distance.get({
                          origin: `${routeJSON['Latitudes'][1]}, ${routeJSON['Longitudes'][1]}`,
                          destination: `${obj['endPointLat']}, ${obj['endPointLong']}`,
                        },
                        function(err, data) {
                            if (err) return console.log(err);
                            leg3 = data.duration;

                             var driverLeaveTime = `time '${obj['arrivalTime']}'  - (interval '${leg1}'  + interval '${leg2}' + '${leg3}')`;
                             var riderPickup = `${driverLeaveTime} + interval '${leg1}'`;
                             var riderDropOff = `${riderPickup} +  interval '${leg2}'`;
                             var riderPickup2 = `time '${obj['departureTime']}' + interval '${leg3}'`;
                             insertMatches(driverLeaveTime, riderPickup, riderDropOff, riderPickup2);
                          });
                        }

                        function insertMatches(driverLeaveTime, riderPickup, riderDropOff, riderPickup2){
                        db.one("SELECT last_value as \"currval\" from \"riderRoutes_routeID_seq\"") // get the rider route ID in the current route table.
                              .then(function(data2){
                                  var riderID = parseInt(data2.currval);
                                  riderID++;
                                  db.one(`select ${driverLeaveTime} as \"driverLeaveTime\"`)
                                   .then(function(driverLeave){
                                     db.one(`select ${riderPickup} as \"riderPickupTime\"`)
                                     .then(function(riderPickupTime){
                                      db.one(`select ${riderDropOff} as \"riderDropOffTime\"`)
                                      .then(function(riderDropOffTime){
                                   db.one(`select ${riderPickup2} as \"riderPickup2Time\"`)
                                      .then(function(riderPickup2Time){
                                db.query("INSERT INTO carpool.\"Matches\"(\"riderID\", \"driverID\",  \"driverRouteID\", \"Status\", \"riderRouteID\", \"driverLeaveTime\", \"riderPickupTime\", \"riderDropOffTime\", \"riderPickupTime2\") values($1, $2, $3, $4, '$5', $6, $7, $8, $9)",[userID, obj['driverID'], obj['routeID'], "Awaiting rider request.", riderID, driverLeave.driverLeaveTime, riderPickupTime.riderPickupTime, riderDropOffTime.riderDropOffTime, riderPickup2Time.riderPickup2Time] ); // insert rider and driver details into Matches table.
                                });
                                });
                              });
                            });
                          });
                        }
}
}
db.any("INSERT INTO carpool.\"notificationLog\"(\"userID\", \"notificationType\", \"Date\", \"Read\") values ($1, $2, $3, $4)", [userID, "Match", 'now', 'false']); // Insert a notification into table when there is a match.
db.one("SELECT \"deviceToken\" from carpool.\"Users\" where \"userID\" = $1", [userID])
.then(function(result) {
  let notification = new apn.Notification();
   notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600; // will expire in 24 hours from now
  notification.badge = 2;
  notification.sound = "ping.aiff";
  notification.alert = "You have a new match!";
  notification.payload = {'messageFrom': 'Notifications are working!'};

   // Replace this with your app bundle ID:
   notification.topic = "com.CSC4996.CarpoolApp";

   // Send the actual notification
  apnProvider.send(notification, result.deviceToken).then( result => {
  // Show the result of the send operation:
     console.log(result);
  });
})
          }
       else {
          console.log("No match found.");
       }
     });
     var addRiderRouteQuery = "INSERT INTO carpool.\"Routes\"(\"riderID\", \"departureTime\", \"arrivalTime\", \"startPointLong\", \"startPointLat\", \"endPointLong\", \"endPointLat\", \"Name\", \"Days\", \"Matched\", \"Driver\") values($1, $2, $3, $4, $5, $6, $7, $8, $9, 'false', 'false')"; // insert Rider's route into Route table.
    db.any(addRiderRouteQuery, [
      userID, routeJSON['departureTime'], routeJSON['arrivalTime'], routeJSON['Longitudes'][0], routeJSON['Latitudes'][0], routeJSON['Longitudes'][1], routeJSON['Latitudes'][1], routeJSON['Name'], routeJSON['Days']])
      .then(function () {
        console.log("Succesfully added route.");
        var setGeographyQuery = "UPDATE carpool.\"Routes\" SET startPoint = ST_POINT (\"startPointLat\", \"startPointLong\"), endPoint = ST_POINT (\"endPointLat\", \"endPointLong\")"; // Set geography objects based on coordinates entered by user.
        db.none(setGeographyQuery)
        .then(function () {
          console.log("Geographies Set.");
        });


        res.status(200)
          .json({
            status: 'Success',
            message: 'Rider route stored.'
          });
      })

      .catch(function (err) {
        console.log('error adding route:', err);
      });

 }

});





module.exports = router;
