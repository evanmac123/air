Airbo = window.Airbo || {};


Airbo.FirstTileHint = (function(){

  var tileSelector = ".tile-wrapper"
    ,pingTitle = "Tile Tooltip Seen", 
    config = {
    showStepNumbers: false,
    scrollToElement: false,
    overlayOpacity: 0,
    doneLabel: "Got it"
  };

  function hasTiles(){
    return $(tileSelector).length > 0
  }

  function initIntro() {
    if(hasTiles()) {
      var options = {
        steps: [
          {
            element: $('.tile-wrapper')[0],
            intro: "Click on the Tile to begin.",
            position: 'top'
          },
        ],
      };

      options = $.extend({},config,options);
      intro = introJs();
      intro.setOptions(options);
      intro.oncomplete(function() {
        Airbo.Utils.ping("Tile Tooltip Seen", {action: "Clicked 'Got it'"});
        setFirstTileHintIntroToSeen()
      });

      Airbo.Utils.ping("Tile Tooltip Seen", {action: "Displayed"});
      intro.start();
    }
  }

  function setFirstTileHintIntroToSeen(){
    $.ajax({
      url: '/user_intros',
      type: 'PUT',
      data: {"intro": "displayed_first_tile_hint"},
      success: function(response) {
      },
      error
    });
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
