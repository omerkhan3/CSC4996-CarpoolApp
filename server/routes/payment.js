var express = require('express');
var router = express.Router();
var braintree = require('braintree');
//var firebase = require('firebase');
var admin = require('firebase-admin');  // we create an instance of the module "braintree"

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
  })
});

router.get("/getPaymentMethod", function (req, res) {
var userID = req.query.userID;
	gateway.customer.find("customerToken", function(err, customer) {
	customer.paymentMethods,
	payload.details.lastFour;
	db.query("select \"Users\".\"userID\", \"Users\".\"customerToken\" from carpool.\"Users\" where \"Users\".\"userID\" = $1", userID)
	})
});


//router.get('/recentPayments', function (req, res, next) {
//var userID = req.query.userID;
//console.log(userID);
//db.query(`select \"userID\", \"Amount\", \"Time\" from carpool.\"paymentHistory\" where \"Time\" >= 'now'`)
//db.query("select \"paymentHistory\".\"userID\", \"paymentHistory\".\"Time\" from carpool.\"paymentHistory\" where \"paymentHistory\".\"userID\" = $1", userID)
//.then(function(data) {
//res.send(data);
//  });
//});

router.post("/checkout", function (req, res) {
  var userID = req.query.userID;
  // Use the payment method nonce here
  var nonceFromTheClient = req.body.payment_method_nonce;

  gateway.transaction.sale({
        amount: "10.00",  // we have hardcoded $10 for now for all transactions, we will eventually need to add "amount" field to our HTTP message from client.
        paymentMethodNonce: nonceFromTheClient,  // we use the nonce received from client.
        db.none("INSERT INTO carpool.\"Users\"(\"userID\", \"customerToken\") values($1)");
        customer: {
        	id: "customerToken"
        },
        options: {
          storeInVaultOnSuccess: true
          //submitForSettlement: true  // this commad is what tells Braintree to process the transaction.
        }
      }, function(err, result) {
          if (result.success) {
            result.success;
            result.transaction.type;
            result.transaction.status;
          } else {
          console.log(err);
            res.status(500).send(err);
          }
      }),
      gateway.customer.create ({
        	id: "customerToken",
        	paymentMethodNonce: nonceFromTheClient
        	db.any("INSERT INTO carpool.\"Users\"(\"userID\", \"customerToken\") values($1, $2)");
      	}, function(err, result) {
          if (result.success) {
            result.success;
            result.transaction.type;
            result.transaction.status;
          } else {
          console.log(err);
            res.status(500).send(err);
          }
      })
});
      

module.exports = router;
