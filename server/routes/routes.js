var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var firebase = require('firebase');
var admin = require('firebase-admin');
var router = express.Router();


router.post('/', function(req, res, next) {
 var userInfo = req.body.userInfo;
 var userJSON = JSON.parse(userInfo);
 var userID = userJSON['userID'];
 console.log(userJSON);
/* db.none("INSERT INTO carpool.\"Users\"(\"userID\", \"firstName\", \"lastName\", \"email\") values($1, $2, $3, $4)", [
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
   /*/
});





module.exports = router;
