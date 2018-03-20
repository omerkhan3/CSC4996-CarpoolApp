var express = require('express');
var router = express.Router();
var braintree = require('braintree');
var firebase = require('firebase');
var admin = require('firebase-admin'); 

var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,
    merchantId:   '263226vjm82nytf2',
    publicKey:    'zprfpjrj64cpz4hr',
    privateKey:   '06195f7e1a9007cc81e2ad48899682da'
});

router.get("/client_token",function (req, res) {
  gateway.clientToken.generate({
  customerId: "12345"
  }, function (err, result) {
  res.send(result.clientToken)
  });
});

router.post("/checkout", function (req, res) {
  var nonceFromTheClient = req.body.payment_method_nonce;
  
      gateway.transaction.sale({
        amount: "10.00",  
        paymentMethodNonce: nonceFromTheClient,  
        customer: {
        	id: "aCustomerId"
        },
        options: {
          storeInVaultOnSuccess: true
          //submitForSettlement: true  
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

//router.get('/Payments', function(req, res, next) {
//	var userID = req.query,userID;
//	//var paymentsQuery = "select         //will be added
//	db.query(paymentsQuery, userID)
//	.then(function(data) {
//	console.log(data);
//	res.send(data);
//	});
//});


module.exports = router;
