Airbo = window.Airbo ||{}

Airbo.StarterKitActivationIntro= (function(){
  var intro
    , currCookie
    , anatomyIntroSelector= ".public-board .tile_holder"
    , viewTileIntroSelector= ".public-board #tile_wall"
    , openBoardIntroSelector= ".board_card #open_board"
    , anatomyCookie= "tile-anatomy"
    , viewTileCookie= "view-tile"
    , anatomySeen = Airbo.CookieMonster.getCookie(anatomyCookie)
    , viewTileSeen = Airbo.CookieMonster.getCookie(viewTileCookie)
    , config = { showStepNumbers: false, skipLabel: 'Exit Intro', doneLabel: 'Got it', tooltipClass: "airbo_preview_intro", nextLabel: "Got it", prevLabel: "Back" }
    , pingName = {
        "tile_holder": "Tile",
        "tile_full_image": "Image",
        "tile_headline": "Text",
        "tile_supporting_content": "Interaction"
      }
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

  function introViewTilePing() {
    // var game = $("body").data("board-id");
    Airbo.Utils.ping("Viewed Parent Board", {"Saw Tile Prompt": true});
  }

  function initTileAnatomyIntro(){
   var nextLabels= ["Why Are Tiles Engaging?", "Where Does Content Go?", "What are points?", "Why are Tiles Interactive?" ]
     , currStep = 0
   ;
    var  options = {
      nextLabeL: nextLabels[0], 
      steps: [
        {
          element: anatomyIntroSelector,
          intro: "Tiles capture employee attention. You can copy and modify Tiles, or create your own.",
          position: "top"
        },
        {
          element: document.querySelector('.tile_full_image'),
          intro: "Images capture employee attention so they want to read your content.",

          position: 'bottom',
          step: 1
        },
        {
          element: document.querySelector('.tile_texts_container'),
          intro: "Content is kept short for short attention spans. You can link employees to more info on your intranet or any web page",
          position: 'bottom',

          step: 2
        },
   
        {
          element: '.tile_points_bar',
          intro: "Points reward the employee for reading, answering questions and taking actions. Some HR pros provide employees with prizes.",
          position: 'bottom',

          step: 3
        },

        {
          element: '.multiple_choice_group',
          intro: "Interactions are fun for employees and provides data on exactly who read and took an action. Try it by clicking one of the buttons.",
          position: 'bottom',

          step: 4
        },
      ]
    };

    currCookie= anatomyCookie;
    options = $.extend({},config, options)
    intro.setOptions(options);

    intro.onafterchange(function(targetElement) {

      $(".introjs-tooltip").css("left", 0)
      $(".introjs-prevbutton").hide();
      $(".introjs-nextbutton").addClass("button-outlined-big");
    });

    intro.onchange(function(targetElement) {
      var el = $(targetElement);

      $(".introjs-tooltip").css("left", 0)
      if(el.hasClass("multiple_choice_group")){

      introAnatomyPing(el);
        $(".introjs-skipbutton").addClass("button-outlined-big");
        $(".introjs-nextbutton").hide();
      }
    });
  }

  function initViewTileIntro(){
    currCookie= viewTileCookie;
    var options = {
      overlayOpacity: 0,
      tooltipClass: "airbo_preview_intro small",
      steps: [{
        element:  document.querySelector(".tile_thumbnail"),
        intro: "Please click on one of the Tiles below",
        position: "top",
      },
      ]
    };

    options = $.extend({},config,options)
    intro.setOptions(options);
    intro.onafterchange(function(targetElement) {
      $(".introjs-skipbutton").hide();
    });
  }


  function initOpenBoardIntro(){
    var options = {
      //overlayOpacity: 0,
      tooltipClass: "airbo_preview_intro small",
      steps: [{
        element:  document.querySelector(".board_card"),
        intro: "Start by opening this board",
        position: "top",
      },
      ]
    };

    options = $.extend({},config,options)
    intro.setOptions(options);
    intro.onafterchange(function(targetElement) {
      $(".introjs-skipbutton").hide();
    });
  }

  function initIntro() {
   var inactivation = false;
    intro = introJs();
    if(!anatomySeen && $(anatomyIntroSelector).length >0){
      inactivation =true;
      initTileAnatomyIntro();
      
    }

    if(!viewTileSeen && $(viewTileIntroSelector).length >0){
      inactivation =true;
      initViewTileIntro();
    }

 
    if((openBoardIntroSelector).length >0){
      inactivation =true;
      initOpenBoardIntro();
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

  function setCookie(){
      Airbo.CookieMonster.setCookie(currCookie, "true");
  }

  function initCloseOnTileInteraction(){
    $("body").on("click", ".right_multiple_choice_answer, .wrong_multiple_choice_answer", function(){
     intro.exit();
    });
  }

  function run(){
    intro.start();
  }

  function init(){
      initCloseOnTileInteraction();
      initIntro();
  }

  return {
    init: init,
    run: run
  }

}())

$(function(){
  Airbo.StarterKitActivationIntro.init();
});
