
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

Airbo.Utils = {

  supportsFeatureByPresenceOfSelector: function(identifier){
    return $(identifier).length > 0
  },
  noop:  function(){},

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

  mediumEditor:  (function() {
    return {
      init: function() {
        $('.medium-editable').each(function(){

          var editor = new MediumEditor(this, {
            staticToolbar:true, 
            placeholder: $(this).data("placeholder"),
            firstHeader: 'h1',
            secondHeader: 'h2',
            buttons: ['header1', 'header2', 'bold', 'italic', 'orderedlist', "image"]
          });

          $(this).html($("#" + $(this).data("field")).val());


          $(this).on('input', function() {
            var textLength = $(this).text().trim().length,
            fieldName = $(this).data('field')
            field = $("#" + fieldName)
            if(textLength > 0){
              field.val($(this).html());
              field.blur();
            }else{
              field.val("");
              field.blur();
            }
          });
        })
      }
    };
  }())

}

Airbo.LoadedSingletonModules = [];

