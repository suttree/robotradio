// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .
//= require audiojs


$(function() { 
  // Setup the player to autoplay the next track
  // mostly taken from http://kolber.github.io/audiojs/demos/test6.html
  var a = audiojs.createAll({
    trackEnded: function() {
      var next = $('.links .link .playing').closest('.link').next();
      if (!next.length) next = $('.links .link').first();
      next.addClass('playing').siblings().removeClass('playing');
      audio.load($('a.track', next).attr('data-src'));
      title = $('a.track', next).attr('data-title');
      $('h3.meta.showtitle').text(title);
      audio.play();
    }
  });
  var audio = a[0];

  if ($('.links .link').attr('data-page') == 'permalink') {
    // preload w/ ondemand
    first = $('.links .link').attr('data-src');
    title = $('.links .link').attr('data-title');
    audio.load(first);
    $('h3.meta.showtitle').text(title);
  } else {
    // preload w/ livestream
    audio.load('http://radiorobot.troisen.com:8080/stream');
    $('h3.meta.showtitle').text('On air');
  }

  $('.links .link a.track').click(function(e) {
    e.preventDefault();
    $(this).parent().parent().addClass('playing').siblings().removeClass('playing');

    file = $(this).attr('data-src');
    title = $(this).attr('data-title');
    url = $(this).attr('data-url');
    audio.load(file);
    $('h3.meta.showtitle').text(title);
    audio.play();
  });

  // Keyboard shortcut
  $(document).keydown(function(e) {
    var unicode = e.charCode ? e.charCode : e.keyCode;
    if (unicode == 32) {
      audio.playPause();
    }
  })
});

$(document).on('ready page:load', function(event) {
  Turbolinks.enableProgressBar();
});

$(function(){ $(document).foundation(); });
