//= require jquery
//= require jquery_ujs
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require autosize
//= require masonry.pkgd.min.js
//= require imagesloaded.pkgd.min.js
//= require airbo
//= require_tree ./utils
//=require ./internal/tile_manager/first_tile_hint


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

(function($){
  $(function(){
    Airbo.init();
  });

})(jQuery);
