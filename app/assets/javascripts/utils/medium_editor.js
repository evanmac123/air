var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.mediumEditor = (function() {
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
        extensions: {
          anchorPreview: new Airbo.CustomAnchorPreview(),
          anchor: new Airbo.CustomAnchorForm()
        },
        staticToolbar:true,
        buttonLabels: 'fontawesome',
        targetBlank: true,
        // anchor: {
        //   linkValidation: true,
        // },
        toolbar: {
         buttons: ['bold', 'italic', 'underline', 'unorderedlist', 'orderedlist', "anchor"]
        }
      };

      editor = new MediumEditor(this, $.extend(defaultParams, params) );
      editor.trigger("focus");

      fieldName = $(this).data('field')
      field = $("#" + fieldName);
      content =  field.val();
      editor.setContent(content);

      editor.subscribe('blur', function (event, editable) {
        var obj =$(editable),  textLength = obj.text().trim().length;
        var val = obj.html();
        var re = new RegExp( /(<p><br><\/p>)+$/g);
        field.val( val.replace(re, "") );
      });


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

}());
