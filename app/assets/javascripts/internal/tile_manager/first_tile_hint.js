Airbo = window.Airbo || {};


Airbo.FirstTileHint = (function(){
  var config = {
    showStepNumbers: false,
    showButtons: false,
    scrollToElement: false,
    overlayOpacity: 0,
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
