//= require jquery
//= require jquery.validate
//= require jquery.validate.additional-methods



//FIXME add to airbo utils
function isIE11() {
  return !!window.MSInputMethodContext;
};

function isIE() {
  var myNav;
  myNav = navigator.userAgent.toLowerCase();
  if (myNav.indexOf('msie') !== -1) {
    return parseInt(myNav.split('msie')[1]);
  } else if (isIE11()) {
    return 11;
  } else {
    return false;
  }
};




var Airbo = window.Airbo || {};

//FIXME Remove Deprecated PAGes features

Airbo.Utils = {

  supportsFeatureByPresenceOfSelector: function(identifier){
    return $(identifier).length > 0
  },

  Pages: {
    TILE_BUILDER: "#new_tile_builder_form",
    TILE_STATS_CHART: "#new_tile_stats_chart_form",
    TILE_STATS_GRID: "#tile_stats_grid",
    SURVEY_TABLE: "#survey_table"
  },

  isAtPage: function(identifier){
    return $(identifier).length > 0
  },

  noop:  function(){},

  urlParamValueByname: function getQueryVariable(variable){
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
      var pair = vars[i].split("=");
      if(pair[0] == variable){
        return pair[1];
      }
    }
    return(false);
  },

  validationConfig: {

    errorPlacement: function(error, element) {
      element.parent().append(error);
    },

    errorClass: "err",

    errorElement: "label",

    highlight: function(element, errorClass, validClass) {
      $(element).addClass("error").removeClass(errorClass);
    },

    unhighlight: function(element, errorClass, validClass) {
      $(element).removeClass("error");
    }
  },

  confirmWithRevealConfig: {
    modal_class: 'tiny confirm-with-reveal destroy_confirm_modal',
    ok_class: 'confirm',
    cancel_class: 'cancel',
    password: false,
    title: "",
    reverse_buttons: true
  },

  mediumEditor:  (function() {
    var editor, field, fieldName;

    function reset(){
      if(editor){
        editor.destroy();
      }
    }

    function init(params) {
      params = params || {};
      reset();

      $('.medium-editable').each(function(){

        defaultParams = {
          staticToolbar:true,
          buttonLabels: 'fontawesome',
          targetBlank: true,
          anchor: {
           linkValidation: true,
          },
          toolbar: {
           buttons: ['bold', 'italic', 'underline', 'unorderedlist', 'orderedlist', "anchor"]
          }
        };
        editor = new MediumEditor(this, $.extend(defaultParams, params) );
        editor.trigger("focus");

        fieldName = $(this).data('field')
        field = $("#" + fieldName);

        //$(this).html($("#" + $(this).data("field")).val());
        content =  $("#" + $(this).data("field")).val();

        editor.setContent(content);

        editor.subscribe('editableInput', function (event, editable) {
          var obj =$(editable),  textLength = obj.text().trim().length;

          if(textLength > 0){
            field.val(obj.html());
          }else{
            field.val("");
          }

          field.blur();
        });

      })
    }

    return {
      init: init
    };

  }())

}

Airbo.Utils.PluginExtentions = (function(){

  function forJQueryValidator(){

    function addMaxTextLength(){
      $.validator.addMethod("maxTextLength", function(value, element, param) {

        function textLength(value){
          var length = 0, content= $("<div></div>");
          content.html(value).each(function(idx, obj){
            length += $(obj).text().length;
          })

          return length;
        }
        return this.optional(element) || textLength(value) <= param;
      }, jQuery.validator.format("Character Limit Reached"));
    }

    /* --------INVOKE INDIVIDUAL EXTENSIONS HERE---------------*/
    addMaxTextLength();

  }

  function init(){
    forJQueryValidator();
  }
 return {
  init: init
 }

}());

$(function(){
  Airbo.Utils.PluginExtentions.init();
})

//FIXME Deprecated
Airbo.LoadedSingletonModules = [];
