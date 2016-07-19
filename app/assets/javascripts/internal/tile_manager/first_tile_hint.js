Airbo = window.Airbo || {};


Airbo.FirstTileHint = (function(){
  var config = {
    showStepNumbers: false,
    scrollToElement: false,
    overlayOpacity: 0,
    doneLabel: "Got it"
  };
  function initIntro() {
    if($('.tile-wrapper').length == 0){
      return;
    }
    var prompt = "Click on the Tile to begin.";
    var options = {
      steps: [
        {
          element: $('.tile-wrapper')[0],
          intro: prompt,
          position: 'top'
        },
      ],
    };
    options = $.extend({},config,options);
    intro = introJs();
    intro.setOptions(options);
    intro.oncomplete(function() {
      Airbo.Utils.ping("Tile Tooltip Seen", {action: "Clicked 'Got it'"});
    });

    Airbo.Utils.ping("Tile Tooltip Seen", {action: "Displayed"});
    intro.start();
  }
  function init() {
    initIntro();
  }
  return {
    init: init
  }
}());

$(window).on("load", function(){
  if ( $("#tile_wall").data("display-first-tile-hint") == true ) {
    Airbo.FirstTileHint.init();
  }
});
