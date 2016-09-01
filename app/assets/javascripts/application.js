//= require jquery
//= require jquery_ujs
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require autosize
//= require sweetalert/sweetalert.min
//= require  medium-editor.min
//= require chosen.jquery.min
//= require airbo
//= require_tree ./utils


//FIXME add to airbo utils
if (!String.prototype.includes) {
  String.prototype.includes = function(search, start) {
    'use strict';
    if (typeof start !== 'number') {
      start = 0;
    }

    if (start + search.length > this.length) {
      return false;
    } else {
      return this.indexOf(search, start) !== -1;
    }
  };
}

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

})(jQuery)
