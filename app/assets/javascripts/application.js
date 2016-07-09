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
  //var a = audiojs.createAll();
  //var audio = a[0];

  // Setup the player to autoplay the next track
  // mostly taken from view-source:http://kolber.github.io/audiojs/demos/test6.html
  var a = audiojs.createAll({
    trackEnded: function() {
      var next = $('ol li.playing').next().next().next();
      if (!next.length) next = $('ol li').first();
      next.addClass('playing').siblings().removeClass('playing');
      audio.load($('a.track', next).attr('data-src'));
      title = $('a.track', next).attr('data-title');
      $('h2').text(title);
      audio.play();
    }
  });
  var audio = a[0];

  first = $('ol a').attr('data-src');
  title = $('ol a').attr('data-title');
  $('ol li').first().addClass('playing');
  audio.load(first);
  $('h2').text(title);

  $('ol li').click(function(e) {
    e.preventDefault();
    $(this).addClass('playing').siblings().removeClass('playing');

    file = $('a', this).attr('data-src');
    title = $('a', this).attr('data-title');
    url = $('a', this).attr('data-url');
    audio.load(file);
    $('h2').text(title);
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
