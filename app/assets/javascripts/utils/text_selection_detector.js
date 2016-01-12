var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.TextSelectionDetector = (function(){
  var eventTarget, callback;

  function initAutoSelect(cb){
    eventTarget.click(function(){
      $(this).select();
      cb();
    });
  }

  function init(targetSelector, cb){
    eventTarget = $(targetSelector);
    initAutoSelect(cb);
  }

  return {
    init: init
  };

}());
