var Airbo = window.Airbo || {};

Airbo.TileBuilderCharacterCounter = (function() {
  function currentText(field) {
    if (field.is("input") || $(field).is("textarea")) {
      return field.val();
    } else {
      return field.text();
    }
  }

  function updateCharacterCount(field, counter) {
    var currentLength = currentText(field).length,
      leftLength = parseInt(field.attr("maxlength"), 10) - currentLength;

    counter.text("" + leftLength + " characters");
    exceededMaxLength(field, counter, leftLength);
  }

  function canExceedMaxlength(field) {
    return field.data("exceed");
  }

  function exceededMaxLength(field, counter, leftLength) {
    if (!canExceedMaxlength(field)) return;
    if (leftLength < 0) {
      field.addClass("exceeded_maxlength_field");
      counter.addClass("exceeded_maxlength_counter");
    } else {
      field.removeClass("exceeded_maxlength_field");
      counter.removeClass("exceeded_maxlength_counter");
    }
  }

  function init() {
    $("body").on(
      "keyup paste",
      "textarea.answer-editable,  textarea.free-text-entry",
      function(event) {
        var field = $(event.target),
          counterId = "#" + field.data("counterid"),
          counter = $(counterId);
        updateCharacterCount(field, counter);
      }
    );
  }
  return {
    init: init
  };
})();
