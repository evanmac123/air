var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.IntroJs = (function(){
  var intro;
  var defaults = {
    showStepNumbers: false,
    tooltipPosition: "auto",
    tooltipClass: "onboarding-activity",
    doneLabel: "Got it",
    overlayOpacity: 1,
    scrollToElement: true,
    exitOnEsc: false,
    exitOnOverlayClick: false,
  }

  function init(opts){
    var options = $.extend({},defaults, opts)
    intro = introJs();
    intro.setOptions(options);
    return intro;
  }

  return {
    init: init, 
  };

}())
