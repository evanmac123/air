
function isIE() {
  var myNav;
  myNav = navigator.userAgent.toLowerCase();
  if (myNav.indexOf('msie') !== -1) {
    return parseInt(myNav.split('msie')[1]);
  } else {
    return false;
  }
};





var Airbo = window.Airbo || {};

Airbo.Utils = {

  supportsFeatureByPresenceOfSelector: function(identifier){
    return $(identifier).length > 0
  },

}
