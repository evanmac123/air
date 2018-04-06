var Airbo = window.Airbo || {};

Airbo.TileFormValidator = (function() {
  var tileModalSelector = "#tile_form_modal";

  var config = {
    debug: false,
    onfocusout: function(el) {
      if ($(el).is("tile[image_credit]")) {
        return false;
      }
      return true;
    },

    ignore: ["tile[image_credit]"],

    errorclass: "tile_builder_error",

    rules: {
      "tile[supporting_content]": {
        requiredValidator: true,
        maxTextLength: hasLimit
      },
      "tile[answers][]": {
        duplicateAnswerValidator: true,
        minAnswersOptionsValidator: true
      },
      "tile[headline]": {
        headLineValidator: true
      },
      "tile[remote_media_url]": { requiredValidator: true },
      "tile[question_subtype]": { requiredValidator: true },
      "tile[question]": { requiredValidator: true },
      "tile[correct_answer_index]": { requiredValidator: true }
    },

    invalidHandler: function(_form, validator) {
      var errors = validator.numberOfInvalids();
      var modal = $(tileModalSelector);
      var form = $(validator.currentForm);

      if (
        errors &&
        modal.is(":visible") &&
        !forceValidation(form) &&
        !isAutoSaving(form)
      ) {
        modal.animate({ scrollTop: 0 }, "slow");
      }
    },

    messages: {
      "tile[headline]": "Please enter a headline before saving.",
      "tile[question_subtype]": "Question option is required.",
      "tile[correct_answer_index]":
        "Please select one choice as the correct answer.",
      "tile[answers][]": {
        minAnswersOptionsValidator:
          "Please add at least two unique non-blank answer options.",
        duplicateAnswerValidator: "Answer choices must be unique."
      },
      "tile[remote_media_url]": "Please add an image.",
      "tile[supporting_content]": {
        maxTextLength: "Tile content is too long.",
        requiredValidator: "Please add Tile content."
      },
      "tile[question]": "Please add a Tile prompt."
    },

    errorPlacement: function(error, element) {
      if (element.attr("name") === "tile[question_subtype]") {
        error.insertAfter(".quiz_content>.placeholder");
      } else if (element.attr("name") === "tile[remote_media_url]") {
        $(".image-menu").prepend(error);
      } else if (element.attr("name") === "tile[correct_answer_index]") {
        $(".js-answer-controls").prepend(error);
      } else if (element.attr("name") === "tile[answers][]") {
        $(".js-answer-controls").prepend(error);
      } else {
        element.parent().append(error);
      }
    },

    highlight: function(element, errorClass) {
      $(element)
        .parents(".content_sections")
        .addClass(errorClassName(element, errorClass));
    },
    unhighlight: function(element, errorClass) {
      $(element)
        .parents(".content_sections")
        .removeClass(errorClassName(element, errorClass));
    }
  };

  function errorClassName(element, errorClass) {
    var name = $(element).attr("name");
    switch (name) {
      case "tile[question_subtype]":
        return "question_" + errorClass;
      case "tile[correct_answer_index]":
        return "index_" + errorClass;
      case "tile[answers][]":
        return "answer_" + errorClass;
      default:
        return "";
    }
  }

  function forceValidation(form) {
    return form.data("forcevalidation") === true;
  }

  function isAutoSaving(form) {
    return form.data("autosave") === true;
  }

  function formIsNotPlan() {
    return $("#tile_status").val() !== "plan";
  }

  function hasLimit() {
    var form = $("#new_tile_builder_form");

    if (forceValidation(form) || formIsNotPlan()) {
      return 700;
    }
    return 9999999;
  }

  function initHeadlineValidator() {
    var form = $("#new_tile_builder_form");
    $.validator.addMethod("headLineValidator", function(value, element) {
      var imageUrl = $("#remote_media_url").val();
      var imageNotPresent = imageUrl === undefined || imageUrl === "";

      if (forceValidation(form) || imageNotPresent) {
        return $.validator.methods.required.call(this, value, element);
      }

      return true;
    });
  }

  function initDuplicateAnswerValidator() {
    var form = $("#new_tile_builder_form");

    $.validator.addMethod("duplicateAnswerValidator", function() {
      var $answers = $(".answer-editable");
      var notUnique;
      var unique;
      var hash = {};

      $answers.each(function() {
        hash[$(this).val()] = 1;
      });

      unique = !(notUnique = $answers.length > Object.keys(hash).length);

      if (unique) {
        return true;
      } else if (forceValidation(form) && notUnique) {
        return false;
      }

      return true;
    });
  }

  function initMinAnswerOptionsValidator() {
    var form = $("#new_tile_builder_form");

    $.validator.addMethod("minAnswersOptionsValidator", function(
      value,
      element
    ) {
      var answers = $(".answer-editable");
      var conf = $(element)
        .parents(".tile_quiz")
        .data("config");
      var minResponses = conf.minResponses || 0;
      var hasMin = answers.length >= minResponses;

      if (forceValidation(form) && !hasMin) {
        return false;
      }

      return true;
    });
  }

  function initRequiredValidator() {
    var form = $("#new_tile_builder_form");

    $.validator.addMethod("requiredValidator", function(value, element) {
      if (forceValidation(form)) {
        return $.validator.methods.required.call(this, value, element);
      }

      return true;
    });
  }

  function init(formObj) {
    var makeConfig = $.extend({}, Airbo.Utils.validationConfig, config);
    initRequiredValidator();
    initHeadlineValidator();
    initDuplicateAnswerValidator();
    initMinAnswerOptionsValidator();
    return formObj.validate(makeConfig);
  }

  return {
    init: init
  };
})();
