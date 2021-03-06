var express = require('express');
var router = express.Router();

const db = require('../routes/db'); // this is our route to initialize DB connection.
const pgp = db.$config.pgp;

router.post('/register', function(req, res, next) {
 var userInfo = req.body.userInfo;
 var userJSON = JSON.parse(userInfo);
 var userID = userJSON['userID']; // User ID from request.

 db.none(`INSERT INTO carpool.\"Users\"(\"userID\", \"firstName\", \"lastName\", \"Email\", \"Phone\") values('${userID}', '${userJSON['firstName']}', '${userJSON['lastName']}', '${userJSON['email']}', '${userJSON['phone']}')`) // Insert query to store user info into the Users table.
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
db.one(`select \"Users\".\"firstName\", \"Users\".\"lastName\", \"Users\".\"Email\", \"Users\".\"Phone\", \"Users\".\"Biography\" from carpool.\"Users\" where \"Users\".\"userID\" ='${userID}'`) // Read query to get profile information on load.
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
  var userID = userJSON['userID'];
  console.log("Updating Bio.");
  db.query(`UPDATE carpool.\"Users\" SET \"Biography\" = '${userJSON['Biography']}', \"firstName\" = '${userJSON['firstName']}', \"lastName\" = '${userJSON['lastName']}', \"Email\" = '${userJSON['Email']}', \"Phone\" = '${userJSON['Phone']}' where \"userID\" = '${userID}'`) // Update profile query to update biography
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


router.post('/device', function(req, res, next){
  var userInfo = req.body.userInfo;
  var userJSON = JSON.parse(userInfo);
  console.log(userJSON);
  var deviceToken= userJSON['deviceToken'];
  var userID = userJSON['userID'];
  console.log("Updating Bio.");
  db.query(`UPDATE carpool.\"Users\" SET \"deviceToken\" = '${deviceToken}' where \"userID\" = '${userID}'`) // Update profile query to update biography
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
