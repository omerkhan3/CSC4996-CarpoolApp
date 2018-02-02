'use strict';


//We get this from braintree going to the API private key, choosing Node and then copying the code given below
var braintree = require('braintree');
var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,
    merchantId:   '263226vjm82nytf2',
    publicKey:    '22cd4zpmz66c7bpq',
    privateKey:   'a21808516d888faceb0163f9b752d66a'
});


//Request comes in to get token, then uses Braintree SDK (gateway), generates client token and sends it back as a response
router.get('/get_token', function (req, res) 
{
    gateway.clientToken.generate( {}, function(err, response)
    {
        console.log("sending token");
        res.send(response);
    });
});

//The server takes the nonce and charges it $1.00 and then prints the result which is like a receipt where it prints all the details of the transaction
router.post('/pay', function (req, res) 
{
    var nonce = req.body.payment_method_nonce;
    gateway.transaction.sale(
    {
        amount: '1.00', paymentMethodNonce: nonce
    }, function (err, result) 
    {
        if (result.sucess) 
        {
            console.log(result);
        }
    });
});


