#!/usr/bin/env node

var fs = require('fs'),
  Ivona = require('ivona-node'),
  request = require('request'),
  fmetadata = require("ffmetadata");

var ivona = new Ivona({
  accessKey: 'GDNAIWABFZTUS7TFCI5Q',
  secretKey: 'l5tEgLDQzeR85ZuH8/VMvS1Px7Noltuac6ZDjQwQ'
});

var voices = ['Emma', 'Amy']
var voice = voices[Math.floor(Math.random() * voices.length)];

var args = process.argv.slice(2)
var file_name = args[0];

ivona.createVoice(args[1], {
    body: {
      input: {
        data: null,
        type: args[2],
      },
      voice: {
        name: voice,
        language: 'en-GB',
        gender: 'Female'
      }
    }
}).pipe(fs.createWriteStream('tmp/' + file_name));

console.log('tmp/' + file_name);
