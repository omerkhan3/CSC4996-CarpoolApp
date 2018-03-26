var express = require('express');
var router = express.Router();
var braintree = require('braintree');
var firebase = require('firebase');
var admin = require('firebase-admin');  // we create an instance of the module "braintree"

var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,  // this contains credentials for our braintree sandbox account.
    merchantId:   '263226vjm82nytf2',
    publicKey:    'zprfpjrj64cpz4hr',
    privateKey:   '06195f7e1a9007cc81e2ad48899682da'
});

router.get("/client_token",function (req, res) {
  gateway.clientToken.generate({
  customerId: "224286744"
  }, function (err, result) {
  res.send(result.clientToken)
  });
});

router.post("/checkout", function (req, res) {
  // Use the payment method nonce here
  var nonceFromTheClient = req.body.payment_method_nonce;
  
  gateway.transaction.sale({
        amount: "10.00",  // we have hardcoded $10 for now for all transactions, we will eventually need to add "amount" field to our HTTP message from client.
        paymentMethodNonce: nonceFromTheClient,  // we use the nonce received from client.
        customer: {
        	id: "aCustomerId"
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
      });
    });

module.exports = router;
