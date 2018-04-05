var express = require('express');
var router = express.Router();
var braintree = require('braintree');
//var firebase = require('firebase');
var admin = require('firebase-admin');  // we create an instance of the module "braintree"
const db = require('../routes/db'); // configures our connection to the DB.

var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,  // this contains credentials for our braintree sandbox account.
    merchantId:   '263226vjm82nytf2',
    publicKey:    'zprfpjrj64cpz4hr',
    privateKey:   '06195f7e1a9007cc81e2ad48899682da'
});

router.get("/recentPayments", function (req, res, next) {
var userID = req.query.userID;
db.query(`select \"userID\", \"Time\", \"riderID\", \"driverID\", \"rideCost\" from carpool.\"paymentHistory\",\"Matches\"`)
.then(function(data) {
 res.send(data);
  });
});


router.get("/client_token",function (req, res) {
  gateway.clientToken.generate({
  customerId: "customerToken"
  }, function (err, result) {
  res.send(result.clientToken)
  });
});


router.post("/checkout", function (req, res) {
  var userID = req.query.userID;
  
  var ScheduledRide = req.body.ScheduledRide;
  var ScheduledRideJSON = JSON.parse(ScheduledRide);
  //var Amount = ScheduledRideJSON["rideCost"]
  
  var RecentPayments = req.body.RecentPayments;
  var RecentPaymentsJSON = JSON.parse(RecentPayments);
  
  // Use the payment method nonce here
  var nonceFromTheClient = req.body.payment_method_nonce;
  db.query(`select \"userID\", \"customerToken\" from carpool.\"Users\"`)
  gateway.transaction.sale({
        amount: "10.00",  // we have hardcoded $10 for now for all transactions, we will eventually need to add "amount" field to our HTTP message from client.
        paymentMethodNonce: nonceFromTheClient,  // we use the nonce received from client.
        customer: {
        	id: "customerToken"
        },
        options: {
          failOnDuplicatePaymentMethod: true,
          storeInVaultOnSuccess: true,
          submitForSettlement: true  // this command is what tells Braintree to process the transaction.
        }
      }, function(err, result) {
          if (result.success) {
            //db.query(`INSERT INTO carpool.\"paymentHistory\"(\"userID\", \"Amount\", \"Time\") VALUES ('${userID}', '${Time}', '${Amount}') where \"Time\" >= 'now', \"Amount\" = [Amount]`)
            db.query(`INSERT INTO carpool.\"paymentHistory\"(\"userID\", \"Amount\", \"Time\") values ($1, $2, $3)", [userID, ScheduledRideJSON['rideCost'], RecentPaymentsJSON['Time']])
            result.success;
            result.transaction.type;
            result.transaction.status;
          } else {
            console.log(err);
            res.status(500).send(err);
          }
      });
    });

module.exports = router;