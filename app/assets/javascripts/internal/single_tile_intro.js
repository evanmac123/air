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
      tooltipClass: "airbo_preview_intro",

      steps: [
        { 
          element: ".tile_holder",
          intro: "Hi, this walkthrough helps you understand the anatomy of a tile.",
          position: "top"
        },
        {
          element: document.querySelector('.tile_full_image'),
          intro: "All tiles have an image which is a powerful way to get your viewer's attention.",

          position: 'top',
          step: 1
        },
        {
          element: document.querySelector('.tile_headline'),
          intro: "The Headline provides a quick overview of what a Tile is about.",
          position: 'top',

          step: 2
        },
        {
          element: '.tile_supporting_content',
          intro: 'The Supporting Content section is where you fill in the core information you wish to share. There is a 750 character limit but you can always insert a link to documents on the web or your intranet if the 750 characters is not enough.',
          position: 'top',

          step: 3
        },
         {
          element: '.tile_quiz',
          intro: "<p>The Interaction section is where you engage your viewers with a short question you'd like them to answer. </p>The response type can be one of various formats from a simple one button confirmation, to a quiz, multiple choice answer,  to a survey. </p><p>Finally, you can assign a number of points to each Tile which employees earn as they complete the Tile interactions. Use the point totals to setup incentive rewards for employees who engage with your content. </br>Airbo tracks both Tile views completions automatically so you don't have to.</p> Go ahead, try it now.",
          position: 'bottom',

          step: 4
        },
      ]
    });


    intro.onchange(function(targetElement) {
      var el = $(targetElement);
      if(el.hasClass("tile_quiz")==true){
        $(".introjs-skipbutton").addClass("button-outlined-big"); 
        $(".introjs-nextbutton").hide();
      } 
    });
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
    if(introable && $(".tile_holder").length >0){

      initCloseOnTileInteraction();
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
