
//function isIE() {
  //var myNav;
  //myNav = navigator.userAgent.toLowerCase();
  //if (myNav.indexOf('msie') !== -1) {
    //return parseInt(myNav.split('msie')[1]);
  //} else {
    //return false;
  //}
//};


function isIE11() {
  return !!window.MSInputMethodContext;
};

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
};




var Airbo = window.Airbo || {};

Airbo.Utils = {

  supportsFeatureByPresenceOfSelector: function(identifier){
    return $(identifier).length > 0
  },
 
  noop:  function(){},
}

Airbo.LoadedSingletonModules = [];

