

var Airbo = window.Airbo || {};

Airbo.TileAnswers = (function(){
  var params
    , defaultParams = {
        onRightAnswer: Airbo.Utils.noop
      }
    , nerfedAnswerSel = '.nerfed_answer'
    , answerSel = ".js-multiple-choice-answer"
    , rightAnswerSel = answerSel +'.correct'
    , clickedRightAnsCls = "clicked_right_answer"
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
    _.each($('.js-multiple-choice-answer.incorrect'), function(wrongAnswerLink) {
      var target;
      wrongAnswerLink = $(wrongAnswerLink);
      target = wrongAnswerLink.siblings('.answer_target');
      attachWrongAnswer(wrongAnswerLink, target);
    });
  };
  function markCompletedRightAnswer(answer) {
    answer.addClass(clickedRightAnsCls);
  };
  function disableRightAnswers() {
    $(rightAnswerSel).unbind();
    $(rightAnswerSel).on("click", function(event) {
      event.preventDefault();
    });
  }
  function checkInTile() {
    var isAction = $(answerSel).length === 1;
    var isSurvey = $(rightAnswerSel).length > 1;
    return isAction || isSurvey;
  }
  function attachRightAnswerMessage(answer) {
    if ( !checkInTile() ) {
      answer.siblings('.answer_target').html("Correct!").slideDown(250);
    }
  }
  function initEvents() {
    $(nerfedAnswerSel).click(function(event) {
      event.preventDefault();
    });


    $(rightAnswerSel).one("click",correctAnswerClicked);

    attachWrongAnswers();

    initFreeFormText();
  }

  function correctAnswerClicked(event) {
    event.preventDefault();

    var answer = $(this)
      , target = answer.siblings('.answer_target')
    ;
    target.hide();

    if(validateFreeText(answer, target)){
      markCompletedRightAnswer(answer);
      disableRightAnswers();
      attachRightAnswerMessage(answer);

      params.onRightAnswer(answer);
    }
  }

  function validateFreeText(answer, target){
    var freeText = $(".js-free-form-response");

    if(answer.hasClass("free-text")){
      if(freeText.val().trim() === ""){
        showFreeFormError(answer, target);
        $(rightAnswerSel).one("click",correctAnswerClicked);
        return false
      }
    }else{
      //Clear if non free response selected
      freeText.val("");
    }
      return true;
  }


  function showFreeFormError(answer, target){
    target.slideDown(250);

  }

  function initFreeFormText(){
    initShowFreeForm();
    initHideFreeform();
    addFreeResponseCharChaounter();
  }

  function addFreeResponseCharChaounter(){
    if((".js-free-form-response").length > 0){
      addCharacterCounterFor(".js-free-form-response");
    }
  }


 function initShowFreeForm(){
   $("body").on("click", ".js-free-text-show", function(event){
     var other = $(this);
     event.preventDefault();
     $(".js-free-text-panel").show();
     other.hide();
   });
 }

 function initHideFreeform(){
   $("body").on("click", ".js-free-text-hide", function(event){
     event.preventDefault();
     $(".js-free-text-panel").hide();
     $(".js-free-text-show").show();
   });
 }

  function reinitEvents() {
    $("." + clickedRightAnsCls).removeClass(clickedRightAnsCls);
    $(rightAnswerSel).unbind();
    $(nerfedAnswerSel).unbind();
    initEvents();
  }
  function init(initParams) {
    params = $.extend(defaultParams, initParams);
    initEvents();
  }
  return {
    init: init,
    reinitEvents: reinitEvents
  }
}());
