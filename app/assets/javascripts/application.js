//= require jquery
//= require jquery_ujs
//= require jquery.validate
//= require jquery.validate.additional-methods

//= require handlebars
//= require vendor_customization/handlebars
//= require_tree ./templates

//= require autosize
//= require masonry.pkgd.min.js
//= require imagesloaded.pkgd.min.js
//= require airbo
//= require_tree ./utils
//= require ./internal/tile_manager/first_tile_hint
//= require clipboard.js


function isIE11() {
  return !!window.MSInputMethodContext;
}

function isIE() {
  var myNav;
  myNav = navigator.userAgent.toLowerCase();
  if (myNav.indexOf('msie') !== -1) {
    return parseInt(myNav.split('msie')[1]);
  } else if (isIE11()) {
    return 11;
  } else {
    return false;
  }
}

$(function(){
  Airbo.init();

  $('#close-flash').click(function(event) {
    $('#flash, .flash-js').slideUp();
    $('#flash, .flash-js').css('overflow','visible');
  });
});
