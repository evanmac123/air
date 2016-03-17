Airbo = window.Airbo ||{}

Airbo.SingleTileIntro= (function(){
  var intro 
    , introable = true
  ;

  function initIntro() {
    /* if (introShowed) return;
       introShowed = true;
       var menuElWithIntro = $(".preview_menu_item");
       if( menuElWithIntro.data('intro').length == 0 ) return;
       */
    intro = introJs();
    intro.setOptions({
      showStepNumbers: false,
      doneLabel: 'Got it',
      tooltipClass: "airbo_preview_intro"
    });


    intro.onchange(function(targetElement) {
      var el = $(targetElement);
      if(el.data("intro-last-step")==true){
        $(".introjs-skipbutton").addClass("button-outlined-big"); 
        $(".introjs-nextbutton").hide();
      } 
    });

  }

  function run(){
    intro.start();
  }

  function init(){
    if(introable){
      initIntro();
      run();
    }
  }

  return {
    init: init,
    run: run
  }

}())

$(function(){
  Airbo.SingleTileIntro.init();
});
