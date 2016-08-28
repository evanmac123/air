//= require jquery
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require ../../../vendor/assets/javascripts/autosize
//= require airbo
//= require_tree ./utils


//FIXME add to airbo utils
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




