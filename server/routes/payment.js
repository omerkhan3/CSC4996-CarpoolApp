var express = require('express');
var router = express.Router();
var braintree = require('braintree');
var firebase = require('firebase');
var admin = require('firebase-admin'); 

router.post('/Payments/', function(req, res, next) {
console.log(req.body);
var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,
    merchantId:   '263226vjm82nytf2',
    publicKey:    'zprfpjrj64cpz4hr',
    privateKey:   '06195f7e1a9007cc81e2ad48899682da'
});

  app.post("/checkout", function (req, res) {
  // Use the payment method nonce here
  var nonceFromTheClient = req.body.payment_method_nonce;
});
  //var idToken = req.body.idToken;
  
  app.get("/client_token",function (req, res) {
  gateway.clientToken.generate({
  customerId: aCustomerId
  }, function (err, response) {
  var clientToken = response.clientToken
  res.send(response.clientToken);
  });
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

router.get('/Payments', function(req, res, next) {
	var userID = req.query,userID;
	//var paymentsQuery = "select         //will be added
	db.query(paymentsQuery, userID)
	.then(function(data) {
	console.log(data);
	res.send(data);
	});
});


module.exports = router;
