var Airbo = window.Airbo || {};

Airbo.TileFormValidator = (function(){
  var tileModalSelector = "#tile_form_modal";
  var conditionFunction;
  var context = this;

  var config = {
    debug: false,
    onfocusout: function(el, e){
      if($(el).is("tile[image_credit]")){
        return false;
      }
      return true;
    },

    ignore: ["tile[image_credit]"],

    errorclass: "tile_builder_error",

    rules: {
      "tile[supporting_content]": {
        required: isRequired,
        minWords: 1,
        maxTextLength: hasLimit
      },
      "tile[answers][]":{
        required: isRequired,
        duplicateAnswerValidator: true,
        minAnswersOptionsValidator: true
      },
      "tile[headline]":             {headLineValidator: true},
      "tile[remote_media_url]":      { required: isRequired},
      "tile[question_subtype]":      { required: isRequired},
      "tile[question]":              { required: isRequired},
      "tile[correct_answer_index]":  { required: isRequired},
    },

    invalidHandler: function(_form, validator) {
      /*
       * Scrolls first invalid element into view if visible
       */
      var errors = validator.numberOfInvalids();
      var modal = $(tileModalSelector);
      var firstError = $(validator.errorList[0].element);
      var form = $(validator.currentForm);

      if (errors && modal.is(":visible") && !forceValidation(form) && !isAutoSaving(form)) {
        if(firstError.is(":visible")) {
          modal.animate({ scrollTop: firstError.offset().top }, 250);
        } else {
          /* The element is hidden due complex UI use the proxy */
          modal.animate({
            scrollTop: $("#" + firstError.data("proxyid")).offset().top
          }, 1000);
        }
      }
    },

    messages: {
      "tile[question_subtype]": "Question option is required.",
      "tile[correct_answer_index]": "Please select one choice as the correct answer.",
      "tile[answers][]": {
        minAnswersOptionsValidator: "Please add at least two unique non-blank answer options.",
        duplicateAnswerValidator: "Answer choices must be unique.",
      },
      "tile[remote_media_url]": "Please add an image.",
    },

    errorPlacement: function(error, element) {
      if(element.attr("name")=="tile[question_subtype]"){
        error.insertAfter(".quiz_content>.placeholder");
      }
      else if( element.attr("name")=="tile[remote_media_url]"){
        $(".image-menu").prepend(error);
      }
      else if( element.attr("name")=="tile[correct_answer_index]"){
        $(".js-answer-controls").prepend(error);
      }
      else if( element.attr("name")=="tile[answers][]"){
        $(".js-answer-controls").prepend(error);
      }
      else {
        element.parent().append(error);
      }
    },

    highlight: function(element, errorClass) {
      $(element).parents(".content_sections").addClass( errorClassName(element, errorClass) );
    },
    unhighlight: function(element, errorClass) {
      $(element).parents(".content_sections").removeClass( errorClassName(element, errorClass) );
    }
  };

  function errorClassName(element, errorClass) {
    name = $(element).attr("name");
    switch(name) {
      case "tile[question_subtype]":
        errorClass = "question_" + errorClass;
      break;
      case "tile[correct_answer_index]":
        errorClass = "index_" + errorClass;
      break;
      case "tile[answers][]":
        errorClass = "answer_" + errorClass;
      break;
    }

    return errorClass;
  }

  function headlineError(f, s){
    return "Headline is required";
  }

  function forceValidation(form){
    return form.data("forcevalidation") === true;
  }

  function isAutoSaving(form){
    return form.data("autosave") === true;
  }

  function formIsNotDraft(){
    return $("#tile_status").val() !== "draft";
  }

  function isRequired(el){
    var form = $("#new_tile");

    return forceValidation(form) || formIsNotDraft();
  }

  function hasLimit(){
    var form = $("#new_tile_builder_form");

    if(forceValidation(form) || $("#tile_status").val() !=="draft"){
      return 700;
    } else{
      return 9999999;
    }
  }

 function initHeadlineValidator(){
   var form = $("#new_tile_builder_form");
   $.validator.addMethod("headLineValidator", function(value, element, params) {
     var imageUrl = $("#remote_media_url").val();
     if(value !== "") {
       return true;
     } else if(form.data("suggested") === true && value === "") {
       return false;
     } else {
       if (forceValidation(form) || ((imageUrl === undefined || imageUrl === "") && value ==="")){
         return false;
       }

       return true;
     }
   }, function (params, element) {
     return isAutoSaving(form) ? "" : "This field is required";
   });
 }

 function imageUrlNotSet(){

 }

 function initDuplicateAnswerValidator(){
   var form = $("#new_tile_builder_form");

   $.validator.addMethod("duplicateAnswerValidator", function(value, element, params) {
     var answers = $(".answer-editable");
     var values;
     var notUnique;
     var unique;
     var hash ={};

     for(var i = 0; i < answers.length; i++){
       var answer = $(answers[i]).val();
       hash[answer] = 1;
     }

    unique = !(notUnique = answers.length > Object.keys(hash).length);

    if(unique) {
      return true;
    } else if(form.data("suggested") === true && notUnique) {
      return false;
    } else if (forceValidation(form) && notUnique) {
      return false;
    } else{
      return true;
    }
   }, "Answer choices must be unique");
 }

 function initMinAnswerOptionsValidator(){
   var form = $("#new_tile_builder_form");

   $.validator.addMethod("minAnswersOptionsValidator", function(value, element, params) {
     var answers = $(".answer-editable");
     var config = $(element).parents(".tile_quiz").data("config");
     var hasMin;

     if(Object.keys(config).length === 0) {
       return true;
     } else {
       hasMin = answers.length >= config.minResponses;
       if(hasMin) {
         return true;
       } else if(form.data("suggested") === true && !hasMin) {
         return false;
       } else if (forceValidation(form) && !hasMin) {
         return false;
       } else {
         return true;
       }
     }
   }, "Answer choices must be unique");
 }

  function init(formObj) {
    var makeConfig = $.extend({}, Airbo.Utils.validationConfig, config);
    initHeadlineValidator();
    initDuplicateAnswerValidator();
    initMinAnswerOptionsValidator();
    return formObj.validate(makeConfig);
  }

  return {
    init: init
  };

}());
