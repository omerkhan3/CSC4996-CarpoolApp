var express = require('express');
var router = express.Router();
var braintree = require('braintree');
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
  db.one(`select \"Users\".\"firstName\", \"Users\".\"lastName\", \"customerID\" from carpool.\"Users\" where \"Users\".\"userID\" ='${userID}'`) // Read query to get profile information on load.
  .then(function(data) {
    if (data.customerID == null)
    {
    console.log(paymentNonce);
   gateway.customer.create({
      firstName: data.firstName,
      lastName: data.lastName,
      paymentMethodNonce: paymentNonce
}, function (err, result) {
  if (result.customer)
  {
    console.log (result.success);

db.query(`UPDATE carpool.\"Users\" SET \"customerID\" = '${result.customer.id}' where \"userID\" = '${userID}'`)
.then(function (data) {
  console.log ("Successfully stored customer ID and token.");
  console.log(result.customer.paymentMethods.length);

})


}

else {
  console.log("Error: ", err);
}

});
}

else {
  gateway.customer.update(data.customerID, {
  paymentMethodNonce: paymentNonce
}, function (err, result) {
  if (result.customer)
  {
    if (result.customer.paymentMethods.length > 1) {
        		for (var i = 1; i < result.customer.paymentMethods.length; i++)
        		{
        			 gateway.paymentMethod.delete(
        			 	result.customer.paymentMethods[i].token
        		)}
        	}
          console.log("Successly updated payment methods!");
  }
  else{
    console.log("Error");
  }
});
}
})
  .catch(function(error){
      console.log('Error storing payment method:', error)
  });
  res.status(200)
    .json({
      status: 'Success',
      message: 'Payment Method Stored.'
    })
});


router.get("/recentPayments", function (req, res, next) {
var userID = req.query.userID;
db.query(`select \"firstName\", \"Amount\", \"Time\" from (select \"firstName\", \"userID\" from carpool.\"Users\") a JOIN (select * from carpool.\"paymentHistory\" where \"riderID\" = '${userID}') b ON a.\"userID\" = b.\"driverID\"`)
.then(function(data) {
  console.log(data);
 res.send(data);
  })
  .catch(function(error){
      console.log('Error fetching recent payments', error);
  });

});




router.get("/payout", function (req, res, next) {

  var userID = req.query.userID;
  db.query(`select sum(\"Amount\") from carpool.\"paymentHistory\" where \"driverID\" = '${userID}'`)
  .then(function(data) {
    console.log(data);
   res.send(data);
    })
    .catch(function(error){
        console.log('Error fetching recent payments', error);
    });
  });

router.get("/checkMethod", function (req, res, next) {
  var idToken = req.query.idToken;
var userID = req.query.userID;
db.one(`select \"Users\".\"customerID\" from carpool.\"Users\" where \"Users\".\"userID\" = '${userID}'`)
.then(function(data) {
  if (data.customerID == null)
  {
    data.customerID = "NULL";
  }
  res.send(data);
  })
  .catch(function(error){
      console.log('Error fetching recent payments', error);
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
        console.log('Error fetching client token', error);
    });


});

router.post("/checkout", function (req, res) {


  // Use the payment method nonce here
  var ridePayment = req.body.ridePayment;
  var ridePaymentJSON = JSON.parse(ridePayment);
  var driverID = ridePaymentJSON['driverID'];
  var riderID = ridePaymentJSON['riderID'];
  var rideCost = Math.round(ridePaymentJSON['rideCost'] * 100) / 100;
db.one(`select \"Users\".\"customerID\" from carpool.\"Users\" where \"Users\".\"userID\" = '${riderID}'`)
.then(function(data) {
  console.log(data.customerID);
  gateway.transaction.sale({
        amount: rideCost,  // we have hardcoded $10 for now for all transactions, we will eventually need to add "amount" field to our HTTP message from client.
        customerId: data.customerID,
 // we use the nonce received from client.
        options: {
          storeInVaultOnSuccess: true
          //submitForSettlement: true  // this commad is what tells Braintree to process the transaction.
        }
      }, function(err, result) {
          if (result.success) {
            console.log(result.transaction.type);
            console.log(result.transaction.status);
            console.log("Payment Processed");
            db.query(`INSERT into carpool.\"paymentHistory\"(\"driverID\", \"riderID\", \"Time\", \"Amount\") values ('${driverID}', '${riderID}', now()::timestamp - interval '4 hours', ${rideCost})`)
            .then(function() {
              res.status(200)
                .json({
                  status: 'Success',
                  message: 'Payment Made.'
                });
            })
            .catch(function(error){
                console.log('Error inserting into recent payments: ', error)
            });
          } else {
            console.log("Error: ", err);
            res.status(500).send(err);

          }
      });
    })
    .catch(function(error){
        console.log('Error processing payment: ', error)
    });


    });




module.exports = router;
