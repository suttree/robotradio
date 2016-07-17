#!/usr/bin/env node

var fs = require('fs'),
  Ivona = require('ivona-node');

var ivona = new Ivona({
  // gmail.com
  //accessKey: 'GDNAIWABFZTUS7TFCI5Q',
  //secretKey: 'l5tEgLDQzeR85ZuH8/VMvS1Px7Noltuac6ZDjQwQ'
  // suttree.com
  //accessKey: 'GDNAI5JADSIYUGT3DWGQ',
  //secretKey: 'CNvNVrmqBSs4Wo1gQ5OokJQdJOn+kpMuDVV13BBP'
  // somewhere.com
  //accessKey: 'GDNAIWSNGHCUH7H247GA',
  //secretKey: 'WfZzO5fFtAFDO5vSv+wBSAYBjRmucpxazLEQvL6B'
  accessKey: 'GDNAIQLLLEPXXYXXSUOA',
  secretKey: 'nuEVX+YZ6VJniuDkgrTEB+eg87A9gXef4bUqOiV',
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
