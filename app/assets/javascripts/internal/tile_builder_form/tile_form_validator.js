var Airbo = window.Airbo || {};

Airbo.TileFormValidator = (function(){


  var tileModalSelector = "#tile_form_modal"
    , conditionFunction
    , context = this
  ;

  var config= {
    debug: true,

    ignore: [],

    errorclass: "tile_builder_error",

    rules: {
      "tile_builder_form[supporting_content]": {
        required: isRequired,
        minWords: 1,
        maxTextLength: hasLimit
      },
      "tile_builder_form[headline]":             {headLineValidator: true},
      "tile_builder_form[remote_media_url]":      { required: isRequired},
      "tile_builder_form[question_subtype]":      { required: isRequired},
      "tile_builder_form[question]":              { required: isRequired},
      "tile_builder_form[correct_answer_index]":  { required: isRequired},
      "tile_builder_form[answers][]":             { required: isRequired}
    },

    invalidHandler: function(form, validator) {

      /*
       * Scrolls first invalid element into view if visible
       */
      var errors = validator.numberOfInvalids()
        , modal = $(tileModalSelector)
        , firstError = $(validator.errorList[0].element)
      ;

      if (errors && modal.is(":visible") && !forceValidation() && !isAutoSaving()) {

        if(firstError.is(":visible")) {
          modal.animate({
            scrollTop: firstError.offset().top
          }, 250);
        } else {
          /* The element is hidden due complex UI use the proxy */
          modal.animate({
            scrollTop: $("#" + firstError.data("proxyid")).offset().top
          }, 1000);
        }
      }
    },

    messages: {
      "tile_builder_form[question_subtype]": "Question option is required.",
      "tile_builder_form[correct_answer_index]": "Please select one choice as the correct answer.",
      "tile_builder_form[answers][]": "Please provide text for all answer options."
    },

    errorPlacement: function(error, element) {
      if(element.attr("name")=="tile_builder_form[question_subtype]"){
        error.insertAfter(".quiz_content>.placeholder");
      }
      else if( element.attr("name")=="tile_builder_form[correct_answer_index]"){
        $(".after_answers").prepend(error);
      }
      else if( element.attr("name")=="tile_builder_form[answers][]"){
        element.parents(".multiple_choice_group").append(error);
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
      case "tile_builder_form[question_subtype]":
        errorClass = "question_" + errorClass;
      break;
      case "tile_builder_form[correct_answer_index]":
        errorClass = "index_" + errorClass;
      break;
      case "tile_builder_form[answers][]":
        errorClass = "answer_" + errorClass;
      break;
    }
    return errorClass;
  }


  function headlineError(f, s){
    return "Headline is required";
  }

  function forceValidation(){
    return $("#forcevalidation").length >  0 ?  true : false;
  }

  function isAutoSaving(){
    return $("#autosave").length >  0 ?  true : false;
  }

  function formIsNotDraft(){
    return $("#tile_builder_form_status").val() !=="draft"
  }

  function isRequired(el){
    var form = $("#new_tile_builder_form");

    return forceValidation() || formIsNotDraft();

  }


  function hasLimit(){
    var form = $("#new_tile_builder_form");

    if(forceValidation() || $("#tile_builder_form_status").val() !=="draft"){
      return 700;
    }else{
      return 9999999;
    }

  }


 function initHeadlineValidator(){
   $.validator.addMethod("headLineValidator", function(value, element, params) {
     var image_url = $("#remote_media_url").val()
     var form = $("#new_tile_builder_form");
     if(value !== "")
       return true

     else if(form.data("suggested")==true && value === ""){
       return false
     }
     else{
       if (forceValidation() || image_url === undefined || image_url === "" && value==""){
         return false
       }
       return true
     }

   }, function (params, element) {
     return isAutoSaving() ? "Unable to autosave without headline or image present" : "This field is required";
   });
 }

  function init(formObj) {
    makeConfig = $.extend({}, Airbo.Utils.validationConfig, config);
    initHeadlineValidator()
    return formObj.validate(makeConfig);
  }

  return {
    init: init
  }

}());
