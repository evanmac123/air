var Airbo = window.Airbo || {};
Airbo.MarketingSite = Airbo.MarketingSite || {};

Airbo.MarketingSite.StandaloneMarketingSiteForms = (function() {
  function validateSignupRequest() {
    var validCharactersRegex = /^[a-z][- a-z]*[- ]{1}[- a-z]*[a-z]$/i;
    function fullname_valid(value) {
      return validCharactersRegex.test(value);
    }

    $.validator.addMethod(
      "custom_fullname",
      function(value, element) {
        return fullname_valid(value);
      },
      "Please enter your first and last name."
    );

    $("#standalone-marketing-site-form").submit(function(event) {
      var form = $("#standalone-marketing-site-form");
      var config = {
        onkeyup: false,
        rules: {
          "lead_contact[organization_name]": {
            required: true
          },
          "lead_contact[email]": {
            required: true,
            email: true
          },
          "lead_contact[name]": {
            required: true,
            custom_fullname: true
          },
          "lead_contact[phone]": {
            required: true,
            phoneUS: true
          },
          "lead_contact[organization_size]": {
            required: true
          }
        },
        messages: {
          "lead_contact[company]": {
            required: "Please enter a company name."
          },
          "lead_contact[name]": {
            required: "Please enter your first and last name."
          },
          "lead_contact[email]": {
            required: "Please enter your work email."
          },
          "lead_contact[phone]": {
            required: "Please enter your phone number."
          }
        },
        errorPlacement: function(error, element) {
          var placement = $(element).data("error");
          if (placement) {
            $(placement).append(error);
          } else {
            error.insertAfter(element);
          }
        }
      };

      config = $.extend({}, Airbo.Utils.validationConfig, config);
      var validator = form.validate(config);

      if (!form.valid()) {
        event.preventDefault();
        validator.focusInvalid();
      } else {
        var email = form.children("#lead_contact_email").val();

        Airbo.MarketingSite.Pings.standaloneFormPings(email);
      }
    });
  }

  function init() {
    validateSignupRequest();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent("#standalone-marketing-site-form")) {
    Airbo.MarketingSite.StandaloneMarketingSiteForms.init();
  }
});
