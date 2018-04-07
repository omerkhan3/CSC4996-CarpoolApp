var express = require('express');
var router = express.Router();
var braintree = require('braintree');
//var firebase = require('firebase');
var admin = require('firebase-admin');  // we create an instance of the module "braintree"
const db = require('../routes/db'); // configures our connection to the DB.
const pgp = db.$config.pgp;
var gateway = braintree.connect({
   environment:  braintree.Environment.Sandbox,  // this contains credentials for our braintree sandbox account.
   merchantId:   'kjjqnn2gj7vbds9g',  // since this is a sandbox account, we have hardcoded values, but we will need to store elsewhere for security reasons when in production.
   publicKey:    's5vyx5cn9s7w2m6h',
   privateKey:   '5f05063b48df7ba47d16d1380a7b3b93'
});

router.post("/create",function (req, res) {
  var paymentInfo = req.body.paymentInfo;
  var paymentJSON = JSON.parse(paymentInfo);
  var userID = paymentJSON['userID'];
  var paymentNonce = paymentJSON['paymentMethodNonce'];
console.log(paymentInfo);

  db.one(`select \"Users\".\"firstName\", \"Users\".\"lastName\" from carpool.\"Users\" where \"Users\".\"userID\" ='${userID}'`) // Read query to get profile information on load.
  .then(function(data) {
    console.log(paymentNonce);
   gateway.customer.create({
      firstName: data.firstName,
      lastName: data.lastName,
      paymentMethodNonce: paymentNonce
}, function (err, result) {
  if (result.customer)
  {
    console.log (result.success);
  // true
  // e.g 160923
db.query(`UPDATE carpool.\"Users\" SET \"customerID\" = '${result.customer.id}' where \"userID\" = '${userID}'`)
.then(function (data) {
  console.log ("Successfully stored customer ID.");
})
//  console.log(result.customer.paymentMethods[0].token);

}
else {
  console.log("Error.");
}

  // e.g f28wm
});
})
  .catch(function(error){
      console.log('Error storing payment method:', error)
  });
  res.status(200)
    .json({
      status: 'Success',
      message: 'Payment Method Stored.'
    });

});


router.get("/recentPayments", function (req, res, next) {
var userID = req.query.userID;
db.query(`select \"userID\", \"Amount\", \"Time\" from carpool.\"paymentHistory\" where \"Time\" >= 'now'`)
.then(function(data) {
 res.send(data);
  });
});


router.get("/client_token",function (req, res) {
  var userID = req.query.userID;
    db.one(`select \"Users\".\"customerID\" from carpool.\"Users\" where \"Users\".\"userID\" ='${userID}'`)
    .then(function(data) {
      gateway.clientToken.generate({
      customerId: data.customerID
      }, function (err, result) {
      res.send(result.clientToken)
      });
    })
    .catch(function(error){
        console.log('Error fetching client token', error)
    });

});

router.post("/checkout", function (req, res) {
  // Use the payment method nonce here
  var nonceFromTheClient = req.body.payment_method_nonce;

  gateway.transaction.sale({
        amount: "10.00",  // we have hardcoded $10 for now for all transactions, we will eventually need to add "amount" field to our HTTP message from client.
        paymentMethodNonce: nonceFromTheClient,  // we use the nonce received from client.
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
