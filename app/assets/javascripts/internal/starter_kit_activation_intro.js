Airbo = window.Airbo ||{}

Airbo.StarterKitActivationIntro= (function(){
  var intro
    , currCookie
    , anatomyIntroSelector= ".public-board .tile_holder"
    , viewTileIntroSelector= ".public-board #tile_wall"
    , anatomyCookie= "tile-anatomy"
    , viewTileCookie= "view-tile"
    , anatomySeen = Airbo.CookieMonster.getCookie(anatomyCookie)
    , viewTileSeen = Airbo.CookieMonster.getCookie(viewTileCookie)
    , config = { showStepNumbers: false, doneLabel: 'Got it', tooltipClass: "airbo_preview_intro", nextLabel: "Next", prevLabel: "Back" }
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
    var  options = {
      steps: [
        {
          element: anatomyIntroSelector,
          intro: "Welcome! This is a quick tour to show you how Tiles will help you engage your team.",
          position: "top"
        },
        {
          element: document.querySelector('.tile_full_image'),
          intro: "Pick an interesting image from our huge library of photos or use one of your own. Images help grab your team's attention and encourage them to click on your Tile.",

          position: 'top',
          step: 1
        },
        {
          element: document.querySelector('.tile_headline'),
          intro: "Give your Tile a good headline to give your team an idea of what it's about.",
          position: 'top',

          step: 2
        },
        {
          element: '.tile_supporting_content',
          intro: 'Add supporting content to communicate what your team needs to learn or do. You can even link to other websites or your intranet.',
          position: 'top',

          step: 3
        },
 {
          element: '.tile_points_bar',
          intro: "Reward your team with points to make Tiles even more engaging. Some HR pros use points to award gift cards or other enticing goodies to their most engaged employees.",
          position: 'top',

          step: 4
        },

        {
          element: '.multiple_choice_group',
          intro: "In this interactive section of your Tile, your team can answer questions or choose from multiple options. You'll get to see who did what and track engagement.<p>The next uncompleted Tile will automatically load after each interaction</p>",
          position: 'bottom',

          step: 5
        },
      ]
    };

    currCookie= anatomyCookie;
    options = $.extend({},config, options)
    intro.setOptions(options);

    intro.onchange(function(targetElement) {
      var el = $(targetElement);
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
