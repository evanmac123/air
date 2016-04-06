var Airbo = window.Airbo || {};

Airbo.TileAnswers = (function(){
  var params
    , defaultParams = {
        onRightAnswer: Airbo.Utils.noop
      }
    , nerfedAnswerSel = '.nerfed_answer'
    , rightAnswerSel = '.right_multiple_choice_answer'
  ;
  function attachWrongAnswer(answerLink, target) {
    answerLink.click(function(event) {
      event.preventDefault();
      target.html("Sorry, that's not it. Try again!");
      target.slideDown(250);
      $(this).addClass("clicked_wrong");
    });
  };
  function attachWrongAnswers() {
    _.each($('.wrong_multiple_choice_answer'), function(wrongAnswerLink) {
      var target;
      wrongAnswerLink = $(wrongAnswerLink);
      target = wrongAnswerLink.siblings('.answer_target');
      attachWrongAnswer(wrongAnswerLink, target);
    });
  };
  function markCompletedRightAnswer(event) {
    $(event.target).addClass('clicked_right_answer');
  };

  function initEvents() {
    $(nerfedAnswerSel).click(function(event) {
      event.preventDefault();
    });
    $(rightAnswerSel).one("click", function(event) {
      event.preventDefault();
      markCompletedRightAnswer(event);
      params.onRightAnswer(event);
    });
    attachWrongAnswers();
  }
  function init(initParams) {
    params = $.extend(defaultParams, initParams);
    initEvents();
  }
  return {
    init: init
  }
}());
