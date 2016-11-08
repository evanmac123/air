var Airbo = window.Airbo || {};

Airbo.GuestUserConversionForm = (function(){
  function initForm() {
    form = $("#guest_conversion_form");
    $("#guest_user_conversion_button").on("click", function(e) {
      $("#errors").hide();
      initFormValidator(form, $(this));
      form.submit();
    });
  }

  function submitForm(form, self) {
    Airbo.Utils.ButtonSpinner.trigger(self);
    $.post( form.attr("action"), form.serialize()).done(function(data) {
      if (data.errors) {
        $("#errors").toggle();
        Airbo.Utils.ButtonSpinner.completeError(self);
      } else {
        var tile_id = $("[data-current-tile-id]").data("current-tile-id");
        var href = tile_id ? "/tiles/" + tile_id : "/activity";
        window.location.href = href;
      }
    });
  }

  function initFormValidator(form, self){
    var config = {
      submitHandler: function() { submitForm(form, self); },
      onkeyup: false,
      rules: {
        "user[name]": {
          required: true,
        },
        "user[email]": {
          required: true,
          email: true
        },
        "user[password]": {
          required: true,
        }
      },
      messages: {
        "user[name]": {
          required: "Please enter your first and last name.",
        },
        "user[email]": {
          required: "Please enter your email.",
        },
        "user[password]": {
          required: "Please enter a password.",
        },
      }
    };

    config = $.extend({}, Airbo.Utils.validationConfig, config);
    validator = form.validate(config);
  }

  function bindConversionReminder() {
    $(".right_multiple_choice_answer, #next, #prev").on("click", function() {
      if($("#completed_tiles_num").text() % 3 === 0) {
        $("#guest-conversion-modal").foundation("reveal","open");
      }
    });
  }

  function init() {
    initForm();
    bindConversionReminder();
  }

  return {
    init: init
  };
}());

$(function() {
  if ($("#guest_conversion_form").length > 0) {
    Airbo.GuestUserConversionForm.init();
  }
});
