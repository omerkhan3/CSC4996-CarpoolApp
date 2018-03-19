var express = require('express');
var path = require('path');
var logger = require('morgan');
var bodyParser = require('body-parser');
var admin = require('firebase-admin');
var index = require('./routes/index');

var serviceAccount = require('./csc4996-carpoolapp-firebase-adminsdk-fsifh-456e34f4e0.json');

var app = express();
admin.initializeApp({
 credential: admin.credential.cert(serviceAccount),
 databaseURL: 'https://csc4996-carpoolapp.firebaseio.com'
});
var users = require('./routes/users');
var payment = require('./routes/payment');
var routes = require('./routes/routes');
var notifications = require('./routes/notifications');
var matches = require('./routes/matches');
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'hbs');
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, 'public')));
app.use('/', index);
app.use('/users', users);
app.use('/payment', payment);  // using the checkout route we are using to handle nonce.
app.use('/routes', routes);
app.use('/notifications', notifications);
app.use ('/matches', matches);
// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
