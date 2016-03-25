Airbo = window.Airbo ||{}

Airbo.StarterKitActivationIntro= (function(){
  var intro
    , currCookie
    , anatomyIntroSelector= ".public-board .tile_holder"
    , viewTileIntroSelector= ".public-board #tile_wall"
    , openBoardIntroSelector= ".board_card_wrapper"
    , anatomyCookie= "tile-anatomy"
    , viewTileCookie= "view-tile"
    , anatomySeen = Airbo.CookieMonster.getCookie(anatomyCookie)
    , viewTileSeen = Airbo.CookieMonster.getCookie(viewTileCookie)
    , config = { 
  showStepNumbers: false,
  skipLabel: 'Exit Intro',
  doneLabel: 'Got it',
  tooltipClass: "airbo_preview_intro",
  nextLabel: "Got it",
  prevLabel: "Back"
    }
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
      overlayOpacity: 0,
      nextLabeL: nextLabels[0], 
      steps: [
        {
          element: anatomyIntroSelector,
          intro: "This is a Tile, an interactive bit of content that's funny and easy to read.",
          position: "top"
        },
        {
          element: document.querySelector('.tile_full_image'),
          intro: "People pay more attention to images than text, so a Tile always starts with an image",

          position: 'top',
          step: 1
        },
        {
          element: document.querySelector('.tile_texts_container'),
          intro: "Text is short so employees can get to the point fast.",
          position: 'top',

          step: 2
        },
   
        {
          element: '.tile_points_bar',
          intro: "Tiles are interactive. That's fun for employees and helps reinforce key points.",
          position: 'top',

          step: 3
        },

        {
          element: '.multiple_choice_group',
          intro: "Employees earn points for each tile they interact with. Next, Interact with the Tile.",
          position: 'top',

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
      tooltipClass: "airbo_preview_intro no-min",
      steps: [{
        element:  document.querySelector("#inc0"),
        intro: "Start by opening this Tile",
        position: "top",
      },
      ]
    };

    options = $.extend({},config,options)
    intro.setOptions(options);
    intro.onafterchange(function(targetElement) {
      var width = $(".introjs-tooltipReferenceLayer").css("width");
      $(".introjs-skipbutton").hide();
      $(".introjs-tooltip").css({"width": width, "left": "0px"});
 
    });
  }


  function initOpenBoardIntro(){
    var options = {
      overlayOpacity: 0,
      tooltipClass: "airbo_preview_intro no-max",
      scrollToElement: false,
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

      var width = $(".introjs-tooltipReferenceLayer").css("width");
      $(".introjs-skipbutton").hide();
      $(".introjs-tooltip").css({"width": width, "left": "0px"});
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

    if($(openBoardIntroSelector).length >0){
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
     exit();
    });
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
  Airbo.StarterKitActivationIntro.init();
});
