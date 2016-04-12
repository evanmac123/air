Airbo = window.Airbo ||{}

Airbo.TileAnatomyTour= (function(){
  var intro
    , currCookie
    , anatomyIntroSelector= ".public-board .tile_holder"
    , anatomyCookie= "tile-anatomy"
    , anatomySeen = Airbo.CookieMonster.getCookie(anatomyCookie)

    , config = { showStepNumbers: false, skipLabel: 'Exit Intro',
  doneLabel: 'Got it',
    nextLabel: 'Got it',
    prevLabel: 'Back', scrollToElement: false,
    }
    , pingName = {
        "tile_holder": "Tile",
        "tile_full_image": "Image",
        "tile_headline": "Text",
        "tile_supporting_content": "Interaction"
      }
    , tileAnatomyTopOffsets = [false, true, true, true, true]
    , tileAnatomyCurrStep = 0
  ;

  function getPingName(el) {
    for (var elClass in pingName) {
      if( el.hasClass(elClass) ){
        return pingName[elClass];
      }
    }
    return "";
  }

  function introAnatomyPing(el) {
    name = getPingName(el);
    Airbo.Utils.ping("Tile - Viewed", {"Tile Onboarding - Viewed": name});
  }


  function initTileAnatomyIntro(){

    options = {
      overlayOpacity: 0,
      tooltipClass: "simple-blue",
      steps: [
        {
          element: $(".right_multiple_choice_answer")[0],
          intro: "(hint) Click me. I'm the right answer",
          position: "bottom",
        },
  
      ]
    };

    currCookie= anatomyCookie;
    options = $.extend({},config, options)
    intro.setOptions(options);

    intro.onafterchange(function(targetElement) {
      repositionResizeTooltip(targetElement);
      $(".introjs-skipbutton").hide();
      $(".introjs-prevbutton").hide();
    });

    intro.onchange(function(targetElement) {
      var el = $(targetElement);

      if(el.hasClass("multiple_choice_group")){

      introAnatomyPing(el);
        $(".introjs-nextbutton").hide();
      }
    });
  }


  function repositionResizeTooltip(targetElement){
  }

  function setPositionTop(targetElement){
    currTop = $(targetElement).offset().top +20;
  }

  function introViewTilePing() {
    Airbo.Utils.ping("Viewed Parent Board", {"Saw Tile Prompt": true});
  }

  function setCookie(){
    Airbo.CookieMonster.setCookie(currCookie, "true");
  }

  function initCloseOnTileInteraction(){
    $("body").on("click", ".right_multiple_choice_answer, .wrong_multiple_choice_answer", function(){
     exit();
    });
  }

  function initIntro() {
    var inactivation = false;
    intro = introJs();
    if(!anatomySeen && $(anatomyIntroSelector).length >0){
      inactivation =true;
      initTileAnatomyIntro();
    }

    intro.onexit(function(targetElement){
      setCookie();
      introViewTilePing();
    });

    intro.oncomplete(function(targetElement){
      setCookie();
      introViewTilePing();
    });

    if(inactivation){
      run();
    }
  }



  function run(){
    intro.start();
  }


  function init(){
      initCloseOnTileInteraction();
      initIntro();
  }

  function exit(){
   intro.exit();
  }


  return {
    init: init,
    run: run,
    exit: exit,
  }

}())

$(function(){
 Airbo.TileAnatomyTour.init();
});
