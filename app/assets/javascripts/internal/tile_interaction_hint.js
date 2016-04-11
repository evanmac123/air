var Airbo = window.Airbo || {}
Airbo.TileInteractionHint = (function(){
  function addHints(){
    intro = introJs();
    intro.setOptions({
      hints: [
        {
          element: $('.right_multiple_choice_answer')[0],
          hint: "This is the right answer. Go ahead click it,  it's fun",
          hintPosition: 'top-middle'
        },
      ]
    });

    intro.addHints();
  }

  function init(){
   addHints();
  }

  return {
    init: init
  }

}())

$(function(){
  $(window).load(function(){
    Airbo.TileInteractionHint.init();
  });
});
