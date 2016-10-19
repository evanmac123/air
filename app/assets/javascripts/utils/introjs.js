var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.IntroJs = (function(){
  var intro,
  tooltipClass = "airbo ",
    highlightClass = "airbo "
  ;

  var defaults = {
    showStepNumbers: false,
    tooltipPosition: "auto",
    doneLabel: "Got it",
    overlayOpacity: 1,
    scrollToElement: true,
    exitOnEsc: false,
    exitOnOverlayClick: false,
    hidePrev: true,
  };


  function applyCss(opts){
    tooltipClass = "airbo " + (opts.tooltipClass || "");
    highlightClass = "airbo " + (opts.highlightClass ||"");
    return {
      tooltipClass: tooltipClass,
      highlightClass: highlightClass
    };
  }

  function init(opts){
    var options = $.extend({},defaults, opts, applyCss(opts));
    intro = introJs();
    intro.setOptions(options);
    return intro;
  }

  return {
    init: init,
  };

}());
