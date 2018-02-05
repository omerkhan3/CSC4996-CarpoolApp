
var express = require('express');
var router = express.Router();
var braintree = require('braintree');

router.post('/', function(req, res, next) {
 var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,
    merchantId:   'kjjqnn2gj7vbds9g',
    publicKey:    'hcvtbjyp4kmzv96d',
    privateKey:   '7160689f99a110ba0d3950c0e0c56863'
});

  // Use the payment method nonce here
  var nonceFromTheClient = req.body.payment_method_nonce;
  // Create a new transaction for $10
  var newTransaction = gateway.transaction.sale({
    amount: '10.00',
    paymentMethodNonce: nonceFromTheClient,
    options: {
      // This option requests the funds from the transaction
      // once it has been authorized successfully
      submitForSettlement: true
    }
  }, function(error, result) {
      if (result) {
        res.send(result);
      } else {
        res.status(500).send(error);
      }
  });
});

module.exports = router;
