
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
    return {
      init: function() {
        $('.medium-editable').each(function(){

          var editor = new MediumEditor(this, {
            staticToolbar:true, 
            buttonLabels: 'fontawesome',
            toolbar: {
              buttons: ['bold', 'italic', 'underline', 'unorderedlist', 'orderedlist', "anchor"]
            }
          });

          $(this).html($("#" + $(this).data("field")).val());

          editor.subscribe('editableInput', function (event, editable) {
            var obj =$(editable),  textLength = obj.text().trim().length
              , fieldName = obj.data('field')
              , field = $("#" + fieldName)
            ;

            if(textLength > 0){
              field.val(obj.html());
            }else{
              field.val("");
            }

            field.blur();
          });

        })
      }
    };
  }())

}

//FIXME Deprecated
Airbo.LoadedSingletonModules = [];
