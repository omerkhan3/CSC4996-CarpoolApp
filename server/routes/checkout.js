
var express = require('express');
var router = express.Router();
var braintree = require('braintree');  // we create an instance of the module "braintree"

router.post('/', function(req, res, next) {
 var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,  // this contains credentials for our braintree sandbox account.
    merchantId:   'kjjqnn2gj7vbds9g',  // since this is a sandbox account, we have hardcoded values, but we will need to store elsewhere for security reasons when in production.
    publicKey:    'hcvtbjyp4kmzv96d',
    privateKey:   '7160689f99a110ba0d3950c0e0c56863'
});

  // Use the payment method nonce here
  var nonceFromTheClient = req.body.payment_method_nonce; // this is the payment nonce provided by UI.  this contains unique payment information used to process transaction.
  // Create a new transaction for $10
  var newTransaction = gateway.transaction.sale({
    amount: '10.00',  // we have hardcoded $10 for now for all transactions, we will eventually need to add "amount" field to our HTTP message from client.
    paymentMethodNonce: nonceFromTheClient,  // we use the nonce received from client.
    options: {
      submitForSettlement: true  // this commad is what tells Braintree to process the transaction.
    }
  }, function(error, result) {
      if (result) {   // error handling for the transaction processing.
        res.send(result);
      } else {
        res.status(500).send(error);
      }
  });
});

module.exports = router;
