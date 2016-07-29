#!/usr/bin/env node

var fs = require('fs'),
    Ivona = require('ivona-node');

var ivona_keys = {
  'gmail': {
    accessKey: 'GDNAIWABFZTUS7TFCI5Q',
    secretKey: 'l5tEgLDQzeR85ZuH8/VMvS1Px7Noltuac6ZDjQwQ'
  },
  'suttree': {
    accessKey: 'GDNAI5JADSIYUGT3DWGQ',
    secretKey: 'CNvNVrmqBSs4Wo1gQ5OokJQdJOn+kpMuDVV13BBP'
  },
  'somewhere': {
    accessKey: 'GDNAIWSNGHCUH7H247GA',
    secretKey: 'WfZzO5fFtAFDO5vSv+wBSAYBjRmucpxazLEQvL6B'
  },
  'somewherehq': {
    accessKey: 'GDNAI4RFIX22H72TPRIQ',
    secretKey: '8WLll1FIwCrTYpz82eI6HYIZ1W6/BHYGKAMNW+Ub'
  },
  'huh': {
    accessKey: 'GDNAIHUY4HDFH4WNMHPQ',
    secretKey: 'IhqMckceXeQu+jTIjCBVIYj4wo1+RXwge+RMZNfg'
  },
  'vam': {
    accessKey: 'GDNAIU6U4I2DTR2ZZBWQ',
    secretKey: 'K3MzESxQaBh0J4DwQsMeDg2FJIipfbBo7on1Rcyl'
  }
}
var keys = Object.keys(ivona_keys);
var random_key = ivona_keys[keys[Math.floor(keys.length * Math.random())]];
var ivona = new Ivona(random_key);

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
