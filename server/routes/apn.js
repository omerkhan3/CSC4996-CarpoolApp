"use strict";

const apn = require('apn');

let options = {
   token: {
     key: "cert_notifications.p8",
    // Replace keyID and teamID with the values you've previously saved.
     keyId: "3KL4446N4D",
     teamId: "3Z83W2KF98"
  },
   production: false
 };

const apnProvider = new apn.Provider(options);

module.exports = { apnProvider: apnProvider, apn: apn };
