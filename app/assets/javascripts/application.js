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
//= require turbolinks
//= require_tree .
//= require audiojs


$(function() { 
  var a = audiojs.createAll();
  var audio = a[0];

  first = $('ol a').attr('data-src');
  $('ol li').first().addClass('playing');
  audio.load(first);
  $('h2').text(first);

  $('ol li').click(function(e) {
    e.preventDefault();
    $(this).addClass('playing').siblings().removeClass('playing');

    file = $('a', this).attr('data-src');
    audio.load(file);
    $('h2').text(file);
    audio.play();
  });
});
