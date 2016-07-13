Airbo = window.Airbo ||{};


Airbo.FirstTileHint = (function(){
  function setTop(){
    var newTop = (parseInt($(".introjs-tooltip").css("top")) +15 )+"px";
    $(".introjs-tooltip").css("top", newTop);
  }
  function setLeftOffset(){
    var refWidth = parseInt($(".introjs-tooltipReferenceLayer").css("width"));
    var introWidth = parseInt($(".introjs-tooltip").css("width"));
    var left = (refWidth-introWidth)/2-10 + "px";
    $(".introjs-tooltip").css("left", left);
  }
  function repositionTooltip(){
    setLeftOffset();
    // setTop();
  }
  function styleTooltipButton(){
    $(".introjs-tooltip .introjs-button").addClass("button").addClass("outlined");
  }
  function restyleTooltip(){
    styleTooltipButton();
    repositionTooltip();
  }
  function initIntro() {
    if($('.tile-wrapper').length == 0){
      return;
    }
    var prompt = "Click on the Tile to begin.";
    var options = {
      tooltipClass: "simple",
      scrollToElement: false,
      hints: [
        {
          element: $('.tile-wrapper')[0],
          hint: prompt,
          hintPosition: 'top-middle'
        },
      ],
    };
    intro = introJs();
    intro.setOptions(options);
    intro.onhintclick(function(event) {
      setTimeout(restyleTooltip, 0);
    });
    intro.onhintclose(function() {
      $(".introjs-hint").removeClass("introjs-hidehint");
      Airbo.Utils.ping("Tile Tooltip Seen", {"action":"Clicked 'Got it'"});
    });
    intro.addHints();
  }
  function showHintToolTip(){
    $(".introjs-hint").trigger("click")
  }
  function init() {
    initIntro();
    showHintToolTip();
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
