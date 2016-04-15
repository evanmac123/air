Airbo = window.Airbo ||{};


Airbo.TileAnswerIntro= (function(){
  var intro
    , currCookie
    , anatomyIntroSelector= ".public-board .tile_holder"
    , anatomyCookie= "tile-anatomy"
    , anatomySeen = Airbo.CookieMonster.getCookie(anatomyCookie)
    , hintClicked = false
  ;

  function setCookie(){
    Airbo.CookieMonster.setCookie(currCookie, "true");
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

  function initOnTileInteraction(){
    $("body").on("click", ".right_multiple_choice_answer",  function(event){
      var id= $(this).data("tile-id");
      var board= $("body").data("board-id");
      setCookie();
      Airbo.Utils.ping("Marketing Page - Answered Tile", {"id":id, "game": board});
      removeHint();
    });
  }

  function removeHint(){
    $(".introjs-hintReference").remove();
    $(".introjs-hints").remove();
  }

  function disableHintExitOnOutsideClick(){
    $("html").on("click","body",  function(event){
      if($(".introjs-tooltip").is(":visible")){
        if($(event.target).is("#next, #prev, .right_multiple_choice_answer, .headerMenu a, .logo_image")){
          removeHint();
        }else{
          event.stopPropagation();
          event.stopImmediatePropagation();
          event.preventDefault();
        }
      }
    });
  }

  function initRedraw(){
    showHintToolTip();
    styleTooltipButton();
    repositionTooltip();
    repositionPulse();
  }

  function initIntro() {

    if(!anatomySeen && $(anatomyIntroSelector).length >0){
      var points = $("#tile_point_value").text();
      var prompt = "This is the right answer. </br>Click to earn " + points + " points"; 
      var options = {
        tooltipClass: "simple",
        scrollToElement: false,
        hints: [
          {
            element: $('.right_multiple_choice_answer')[0],
            hint: prompt,
            hintPosition: 'top-middle'
          },
        ],
      };

      currCookie= anatomyCookie;

      intro = introJs();

      intro.setOptions(options);

      intro.onhintclick(function(event) {
        setTimeout(repositionTooltip, 0);
      });

      intro.onhintclose(function() {
        $(".introjs-hint").removeClass("introjs-hidehint")
      }); 

   

      intro.addHints();
    }
  }


  function init(){
    initIntro();
    initRedraw();
    initOnTileInteraction();
    disableHintExitOnOutsideClick()
  }

  return {
    init: init,
  }

}())


Airbo.LandingPageHandler = (function(){

  function initPingOnBoardOpen(){
    $(".topic").click(function(event){
      event.preventDefault();
      var name = $(this).data("name");
      Airbo.Utils.ping("Marketing Page - Viewed Board", {"name":name});
      window.location = $(this).attr('href');
    })
  }


  function initPingOnTileOpen() {
    $(".tile_thumbnail a").click(function(event){
      var id= $(this).data("id");
      Airbo.Utils.ping("Marketing Page - Viewed Tile", {"id": id});
      window.location = $(this).attr('href');
    });
  }

  function init(){
    initPingOnBoardOpen();
    initPingOnTileOpen();
  }


  return {
   init: init
  }

}())


$(function(){
  Airbo.LandingPageHandler.init();
  $(window).on("load", function(){
    Airbo.TileAnswerIntro.init();
  });
});
