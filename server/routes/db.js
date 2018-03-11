var promise = require('bluebird');
var options = {
  promiseLib: promise
};

var pgp = require('pg-promise')(options);
var conString = "postgres://carpool:carpool2018@carpool.clawh88zlo74.us-east-2.rds.amazonaws.com:5432/carpool"; // This is the connection string to AWS.  We may want to store this in a separate file.
const db = pgp(conString); // db connection.

module.exports = db;
