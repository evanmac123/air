var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.mediumEditor = (function() {
  var editor, field, fieldName;

  function reset() {
    if (editor) {
      editor.destroy();
    }
  }

  function init(params) {
    params = params || {};
    reset();

    $(".medium-editable").each(function() {
      defaultParams = {
        anchor: {
          linkValidation: true
        },
        autoLink: true,
        buttonLabels: "fontawesome",
        targetBlank: true,
        imageDragging: false,
        toolbar: {
          buttons: [
            "bold",
            "italic",
            "underline",
            "unorderedlist",
            "orderedlist",
            "anchor"
          ]
        }
      };

      editor = new MediumEditor(this, $.extend(defaultParams, params));
      editor.trigger("focus");

      fieldName = $(this).data("field");
      field = $("#" + fieldName);
      content = field.val();
      field.data("oldVal", content);
      editor.setContent(content);

      editor.subscribe(
        "blur",
        $.debounce(2000, function(event, editable) {
          var obj = $(editable);
          var textLength = obj.text().trim().length;
          var val = obj.html();
          var oldVal = field.data("oldVal");
          var re = new RegExp(/(<p><br><\/p>)+$/g);

          field.val(val.replace(re, ""));
          field.data("oldVal", field.val());

          if (oldVal !== field.val()) {
            field.change();
          }
        })
      );

      editor.subscribe("editableInput", function(e, editable) {
        var obj = $(editable);
        var textLength = obj.text().trim().length;

        if (textLength > 0) {
          field.val(obj.html());
        } else {
          field.val("");
        }

        field.blur();
      });
    });
  }

  return {
    init: init
  };
})();
