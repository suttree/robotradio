#!/usr/bin/env node

var fs = require('fs'),
  Ivona = require('ivona-node'),
  request = require('request'),
  ffmetadata = require("ffmetadata"),
  util = require('util'),
  exec = require('child_process').exec;

var ivona = new Ivona({
  accessKey: 'GDNAIWABFZTUS7TFCI5Q',
  secretKey: 'l5tEgLDQzeR85ZuH8/VMvS1Px7Noltuac6ZDjQwQ'
});

var entities = new Entities();

var args = process.argv.slice(2);

function createSpeech(data, callback) {
  var concat_list = 'concat:';
  var article = data.title + '\n' + data.contents;
  splitArticle(article).forEach(function (line, i) {
    console.log(line);
    console.log('----')
    // add pauses between title and also when we detect any whitespace-lines
    if (/\S/.test(line)) {
      ivona.createVoice(line, {
          body: {
            voice: {
              name: 'Emma',
              language: 'en-GB',
              gender: 'Female'
            }
          }
      }).pipe(fs.createWriteStream('tmp/text-' + i + '.mp3'));
      concat_list += 'tmp/text-' + i + '.mp3|';
    }
  });

  // could progressively add to the main mp3 here, one file at a time
  // not very performant but better than the hit or miss situation right now?
  callback(concat_list);
}

// TODO use the article title as the filename
function createMP3(concat_list) {
  var cmd = 'ffmpeg -i "' + concat_list.slice(0, -1) + '" -c copy content/' + Date.now() +'.mp3 -y';
  console.log(cmd);
  exec(cmd, {silent:true});
  //exec(cmd);

  // use this to edit the mp3 metadata (add an image, creator, link to article, etc)
  // https://www.npmjs.com/package/ffmetadata
};
