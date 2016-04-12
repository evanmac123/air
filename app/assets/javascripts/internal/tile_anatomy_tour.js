Airbo = window.Airbo ||{}

Airbo.TileAnswerIntro= (function(){
  var intro
    , currCookie
    , anatomyIntroSelector= ".public-board .tile_holder"
    , anatomyCookie= "tile-anatomy"
    , anatomySeen = Airbo.CookieMonster.getCookie(anatomyCookie)
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

    function initTileAnatomyIntro(){
     var points = $("#tile_point_value").text();
     var prompt = "This is the right answer. </br>Click to earn " + points + " points"
      options = {
        overlayOpacity: 0,
        tooltipClass: "simple-blue",
        scrollToElement: false,
        showStepNumbers: false, 
        skipLabel: 'Exit Intro',
        exitOnOverlayClick: false,
        doneLabel: 'Got it',
        nextLabel: 'Got it',
        prevLabel: 'Back', scrollToElement: false,
        steps:[],
        hints: [
          {
            element: $('.right_multiple_choice_answer')[0],
            hint: prompt,
            hintPosition: 'top-middle'
          },
        ],
      };

      currCookie= anatomyCookie;
      intro.setOptions(options);
    }
 
    
    function introViewTilePing() {
      Airbo.Utils.ping("Viewed Parent Board", {"Saw Tile Prompt": true});
    }

    function setCookie(){
      Airbo.CookieMonster.setCookie(currCookie, "true");
    }

    function initCloseOnTileInteraction(){
      $("body").on("click", ".right_multiple_choice_answer",  function(){
        exit();
      });
    }

    function initIntro() {
      intro = introJs();

      intro.onexit(function(targetElement){
        setCookie();
        introViewTilePing();
      });

      intro.oncomplete(function(targetElement){
        setCookie();
        introViewTilePing();
      });

      intro.onchange(function(targetElement) {
        var el = $(targetElement);

        if(el.hasClass("multiple_choice_group")){

          introAnatomyPing(el);
        }
      });

      if(!anatomySeen && $(anatomyIntroSelector).length >0){
        initTileAnatomyIntro();
        intro.addHints();
      }

    }


    function repositionTooltip(){
      setLeftOffset();
      setTop();
    }

    function repositionPulse(){
      var hintTop = parseInt($(".introjs-hint").css("top"));
      $(".introjs-hint").css("top", (hintTop+2) +"px")
    }

    function styleTooltipButton(){
      $(".introjs-tooltiptext .introjs-button").addClass("button").addClass("outlined");
    }

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

    function showHintToolTip(){
      $(".introjs-hint").trigger("click")
    }

    function initRedraw(){
      showHintToolTip();
      styleTooltipButton();
      repositionTooltip();
      repositionPulse();
    }

    function init(){
      initCloseOnTileInteraction();
      initIntro();
      initRedraw();

      $("body").on("click", function(event){
        
        if($(".introjs-tooltip").is(":visible")){
          if($(event.target).is("#next, #prev, .right_multiple_choice_answer")){

            $(".introjs-hintReference").remove();
            $(".introjs-hints").remove();
          }else{
            event.stopPropagation();
            event.stopImmediatePropagation();
            event.preventDefault();
          }
        }
      });

    }

    function exit(){
      intro.exit();
    }


    return {
      init: init,
      exit: exit,
    }

}())

$(function(){
  Airbo.TileAnswerIntro.init();
});
