!/usr/bin/env node

var fs = require('fs'),
  Ivona = require('ivona-node'),
  request = require('request'),
  fmetadata = require("ffmetadata");

var ivona = new Ivona({
  accessKey: 'GDNAIWABFZTUS7TFCI5Q',
  secretKey: 'l5tEgLDQzeR85ZuH8/VMvS1Px7Noltuac6ZDjQwQ'
});

var args = process.argv.slice(2)
var file_name = args[0];

ivona.createVoice(args[1], {
    body: {
      voice: {
        name: 'Emma',
        language: 'en-GB',
        gender: 'Female'
      }
    }
}).pipe(fs.createWriteStream('tmp/ + file_name));
console.log('tmp/' + file_name);
