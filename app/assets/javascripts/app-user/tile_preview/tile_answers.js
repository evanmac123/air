var Airbo = window.Airbo || {};

Airbo.TileAnswers = (function() {
  var params,
    defaultParams = { onRightAnswer: Airbo.Utils.noop },
    nerfedAnswerSel = ".nerfed_answer",
    answerSel = ".js-multiple-choice-answer:not(.custom)",
    rightAnswerSel = answerSel + ".correct",
    clickedRightAnsCls = "clicked_right_answer";

  var CustomHandler = {
    showCustom: function() {
      $(this.panel).hide();
      $(this.showTrigger).show();
    },

    initShow: function() {
      $("body").on(
        "click",
        this.showTrigger,
        function(event) {
          var trigger = event.target;
          event.preventDefault();
          $(this.panel).show();
          $(this.showTrigger).hide();
        }.bind(this)
      );
    },

    initHide: function() {
      $("body").on(
        "click",
        this.hideTrigger,
        function(event) {
          event.preventDefault();
          this.showCustom();
        }.bind(this)
      );
    },

    isInvalid: function() {
      return (
        $(this.response)
          .val()
          .trim() === ""
      );
    },

    handle: function(answer, target) {
      if (this.isInvalid()) {
        this.showError(target);
        resetRightAnswerEvent();
        return false;
      } else {
        return true;
      }
    },

    shouldHandle: function(answer) {
      return answer.hasClass(this.customHandlerCSS);
    },

    isInvalid: function() {
      return (
        $(this.response)
          .val()
          .trim() === ""
      );
    },

    showError: function(target) {
      target.slideDown(250);
    },

    init: function() {
      this.initShow();
      this.initHide();
    }
  };

  var FreeTextHandler = Object.create(CustomHandler);

  FreeTextHandler.showTrigger = ".js-free-text-show";
  FreeTextHandler.hideTrigger = ".js-free-text-hide";
  FreeTextHandler.panel = ".js-free-text-panel";
  FreeTextHandler.response = ".js-free-form-response";
  FreeTextHandler.customHandlerCSS = "js-free-text";

  FreeTextHandler.addFreeResponseCharCounter = function() {
    if ($(this.response).length > 0) {
      addCharacterCounterFor(this.response);
    }
  };

  FreeTextHandler.init = function() {
    CustomHandler.init.call(this);
    this.addFreeResponseCharCounter();
  };

  var CustomFormHandler = Object.create(CustomHandler);

  CustomFormHandler.showTrigger = ".js-custom-form-show";
  CustomFormHandler.hideTrigger = ".js-custom-form-hide";
  CustomFormHandler.panel = ".js-custom-form-panel";
  CustomFormHandler.response = "#custom_form_phone";
  CustomFormHandler.customHandlerCSS = "js-custom-form";

  CustomFormHandler.isInvalid = function() {
    return (
      $(this.response)
        .val()
        .trim() === ""
    );
  };

  // ***************************************
  //  End custom interaction declarations
  // ***************************************

  function resetRightAnswerEvent() {
    $(rightAnswerSel).one("click", correctAnswerClicked);
  }

  function attachWrongAnswer(answerLink, target) {
    answerLink.click(function(event) {
      event.preventDefault();
      target.html("Sorry, that's not it. Try again!");
      target.slideDown(250);
      $(this).addClass("clicked_wrong");
    });
  }

  function attachWrongAnswers() {
    $(".js-multiple-choice-answer.incorrect").each(function(
      idx,
      wrongAnswerLink
    ) {
      var target;
      wrongAnswerLink = $(wrongAnswerLink);
      target = wrongAnswerLink.siblings(".answer_target");
      attachWrongAnswer(wrongAnswerLink, target);
    });
  }

  function markCompletedRightAnswer(answer) {
    answer.addClass(clickedRightAnsCls);
  }

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
    if (!checkInTile()) {
      answer
        .siblings(".answer_target")
        .html("Correct!")
        .slideDown(250);
    }
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

  function initEvents() {
    $(nerfedAnswerSel).click(function(event) {
      event.preventDefault();
    });

    resetRightAnswerEvent();
    attachWrongAnswers();
    initSpecializedTileHandlers();
  }

  function initSpecializedTileHandlers() {
    FreeTextHandler.init();
    CustomFormHandler.init();
  }

  function correctAnswerClicked(event) {
    var answer = $(this),
      target = answer.siblings(".answer_target");
    event.preventDefault();
    target.hide();

    if (validAfterCustomHandling(answer, target)) {
      executeDefaultAnswerClickedProcessing(answer);
    }
  }

  function validAfterCustomHandling(answer, target) {
    var valid = true;
    valid = valid && handleFreeText(answer, target);
    valid = valid && handleCustomForm(answer, target);
    return valid;
  }

  function executeDefaultAnswerClickedProcessing(answer) {
    markCompletedRightAnswer(answer);
    disableRightAnswers();
    attachRightAnswerMessage(answer);
    params.onRightAnswer(answer);
  }

  function handleFreeText(answer, target, cb) {
    if (FreeTextHandler.shouldHandle(answer)) {
      return FreeTextHandler.handle(answer, target);
    } else {
      $(".js-free-form-response").val("");
      return true;
    }
  }

  function handleCustomForm(answer, target) {
    if (CustomFormHandler.shouldHandle(answer)) {
      return CustomFormHandler.handle(answer, target);
    } else {
      $(".js-custom-form").val("");
      return true;
    }
  }

  return {
    init: init,
    reinitEvents: reinitEvents
  };
})();
