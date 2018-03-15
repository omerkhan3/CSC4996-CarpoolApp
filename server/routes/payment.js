var express = require('express');
var router = express.Router();
var braintree = require('braintree');
var firebase = require('firebase');
var admin = require('firebase-admin'); 

router.post('/payment/', function(req, res, next) {
console.log(req.body);
 var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,  
    merchantId:   'kjjqnn2gj7vbds9g',  
    publicKey:    'hcvtbjyp4kmzv96d',
    privateKey:   '7160689f99a110ba0d3950c0e0c56863'
});

  // Use the payment method nonce here
  var nonceFromTheClient = req.body.payment_method_nonce;
  //var idToken = req.body.idToken;
  
  gateway.clientToken.generate({
  customerId: aCustomerId
  }, function (err, response) {
  var clientToken = response.clientToken
  });

  //admin.auth().verifyIdToken(idToken)
   // .then(function(decodedToken) {
      //var uid = decodedToken.uid;
      gateway.transaction.sale({
        amount: '10.00',  
        paymentMethodNonce: nonceFromTheClient,  
        customer: {
        	id: "aCustomerId"
        },
        options: {
          storeInVaultOnSuccess: true
          //submitForSettlement: true  
        }
      }, function(error, result) {
          if (result) {  
            res.send(result);
            options.storeInVaultOnSuccess = true;
          } else {
          console.log(error);
            res.status(500).send(error);
          }
      })
    .catch(function(error) {
      // Handle error
      console.log ("Invalid User.");
    });
});

module.exports = router;
