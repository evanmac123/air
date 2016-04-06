Airbo.TileCarouselPage = (function() {

  function updateNavbarURL(newTileId) {
    var newURL, tag;
    newURL = newTileId.toString();
    tag = getURLParameter('tag');
    if (tag != null) {
      newURL += "?tag=" + tag;
    }
    return History.pushState(null, null, newURL);
  }

  function getURLParameter(sParam) {
    var i, j, ref, sPageURL, sParameterName, sURLVariables;
    sPageURL = window.location.search.substring(1);
    sURLVariables = sPageURL.split('&');
    for (i = j = 0, ref = sURLVariables.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      sParameterName = sURLVariables[i].split('=');
      if (sParameterName[0] === sParam) {
        return sParameterName[1];
      }
    }
  }

  function setUpAnswersForPreview() {
    attachRightAnswersForPreview();
    attachWrongAnswers();
  }

  function attachRightAnswersForPreview() {
    $('.right_multiple_choice_answer').one("click", function(event) {
      event.preventDefault();
      rightAnswerClickedForPreview(event);
      disableAllAnswers();
    });
  }

  function attachWrongAnswer(answerLink, target) {
    return answerLink.click(function(event) {
      event.preventDefault();
      target.html("Sorry, that's not it. Try again!");
      target.slideDown(250);
      return $(this).addClass("clicked_wrong");
    });
  }

  function attachWrongAnswers( ) {
    return _.each($('.wrong_multiple_choice_answer'), function(wrongAnswerLink) {
      var target;
      wrongAnswerLink = $(wrongAnswerLink);
      target = wrongAnswerLink.siblings('.answer_target');
      return attachWrongAnswer(wrongAnswerLink, target);
    });
  }


  function markCompletedRightAnswer(event) {
    return $(event.target).addClass('clicked_right_answer');
  };

  function rightAnswerClickedForPreview(event) {
    markCompletedRightAnswer(event);
    attachRightAnswerMessage(event);
  };

  function disableAllAnswers() {
    return $(".right_multiple_choice_answer").removeAttr("href").unbind();
  }

  function checkInTile() {
    return $(".tile_multiple_choice_answer").length === 1;
  };

  function attachRightAnswerMessage(event) {
    if ( checkInTile() ) {
      return $(event.target).siblings('.answer_target').html("Correct!").slideDown(250);
    }
  }


  function initLinkFixer(){
    Airbo.Utils.ExternalLinkHandler.init();
  }

  function init(){
    grayoutTile();
    //updateNavbarURL(data.tile_id);
    setUpAnswersForPreview();
    ungrayoutTile();
    initLinkFixer();

  }
  return {
    init: init
  }

}());
