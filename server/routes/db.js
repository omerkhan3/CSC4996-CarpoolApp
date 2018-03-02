var promise = require('bluebird');
var options = {
  promiseLib: promise
};

var pgp = require('pg-promise')(options);
var conString = "postgres://carpool:carpool2018@carpool.clawh88zlo74.us-east-2.rds.amazonaws.com:5432/carpool";
const db = pgp(conString);

module.exports = db;
