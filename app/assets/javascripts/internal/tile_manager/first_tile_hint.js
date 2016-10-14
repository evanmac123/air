Airbo = window.Airbo || {};


Airbo.FirstTileHint = (function(){

  var tileSelector = ".tile-wrapper"
    ,pingTitle = "Tile Tooltip Seen", 
    config = {
    showStepNumbers: false,
    scrollToElement: true,
    overlayOpacity: 0,
    doneLabel: "Got it",
    exitOnEsc: true,
    exitOnOverlayClick: true,
    steps: [
      {
        element: ".tile-wrapper:first-of-type",
        intro: "This is the first Tile. We recommend clicking it to begin.",
        position: 'top'
      },
    ],
  };

  function hasTiles(){
    return $(tileSelector).length > 0
  }

  function initIntro(opts) {
    if(hasTiles()) {
      options = $.extend({},config,opts);
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
      error: function(err){
        console.log("Error urable to update :displayed_first_tile_hint on UserIntro");
      }
    });
  }

  function init(opts) {
    initIntro(opts);
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
