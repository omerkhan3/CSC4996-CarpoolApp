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

router.get("/client_token",function (req, res) {
  gateway.clientToken.generate({
  customerId: "customerToken"
  }, function (err, result) {
  res.send(result.clientToken)
  });
});

router.get("/recentPayments", function (req, res, next) {
var userID = req.query.userID;
db.query(`select \"userID\", \"Time\" from carpool.\"paymentHistory\" where \"Time\" >= 'now'`)
.then(function(data) {
 res.send(data);
  });
});

router.post("/checkout", function (req, res) {
  var userID = req.query.userID;
  var paymentInfo = req.body.paymentInfo;
  var paymentJSON = JSON.parse(paymentInfo);
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
          storeInVaultOnSuccess: true
          //submitForSettlement: true  // this commad is what tells Braintree to process the transaction.
        }
      }, function(err, result) {
          if (result.success) {
            db.query(`INSERT INTO carpool.\"paymentHistory\"(\"userID\", \"Time\") VALUES ('${userID}', '${Time}') where \"Time\" >= 'now'`)
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