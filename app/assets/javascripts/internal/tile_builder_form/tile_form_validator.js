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
      "tile_builder_form[headline]":              { required: true },
      "tile_builder_form[remote_media_url]":      { required: isRequired},
      "tile_builder_form[question_subtype]":      { required: isRequired},
      "tile_builder_form[question]":              { required: isRequired},
      "tile_builder_form[correct_answer_index]":  { required: isRequired},
      "tile_builder_form[answers][]":             { required: isRequired}
    },

    invalidHandler: function(form, validator) {
      var errors = validator.numberOfInvalids();
      if (errors) {
        if($(validator.errorList[0].element).is(":visible")) {
          $(tileModalSelector).animate({
            scrollTop: $(validator.errorList[0].element).offset().top
          }, 250);
        } else {
          $(tileModalSelector).animate({
            scrollTop: $("#" + $(validator.errorList[0].element).data("proxyid")).offset().top
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

  function isRequired(el){
    var form = $("#new_tile_builder_form");

    if($("#tile_builder_form_status", form).val() ==="draft"){
      return false;
    }else{
      return true;
    }
  }

  function hasLimit(){
    var form = $("#new_tile_builder_form");
    if($("#tile_builder_form_status", form).val() ==="draft"){
      return 9999999;
    }else{
      return 700;
    }
  }

  function init(formObj) {
    makeConfig = $.extend({}, Airbo.Utils.validationConfig, config);
    return formObj.validate(makeConfig);
  }

  return {
    init: init
  }

}());
