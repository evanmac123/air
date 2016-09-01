var Airbo = window.Airbo || {};

Airbo.SignupRequest= (function(){
  function validateSignupRequestForm() {
    var validCharactersRegex = /^[a-z][- a-z]*[- ]{1}[- a-z]*[a-z]$/i;
    function fullname_valid(value) {
        return validCharactersRegex.test(value);
    }

    $.validator.addMethod("custom_fullname", function(value, element) {
        return fullname_valid(value);
    }, "Please enter your first and last name.");


    $("#signup_request_form").submit(function(event){
      var form = $("#signup_request_form");
      var config={
        onkeyup: false,
        rules: {
          "lead_contact[organization_name]": {
            required: true,
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
            required: true,
          },
        },
        messages: {
          "lead_contact[company]": {
            required: "Please enter a company name.",
          },
          "lead_contact[name]": {
            required: "Please enter your first and last name.",
          },
          "lead_contact[email]": {
            required: "Please enter your work email.",
          },
          "lead_contact[phone]": {
            required: "Please enter your phone number.",
          },
        },
        errorPlacement: function(error, element) {
          var placement = $(element).data('error');
          if (placement) {
            $(placement).append(error);
          } else {
            error.insertAfter(element);
          }
        }
      };

      config = $.extend({}, Airbo.Utils.validationConfig, config);
      var validator = form.validate(config);

      if(!form.valid()){
        event.preventDefault();
        validator.focusInvalid();
      }
    });
  }

  function init() {
    validateSignupRequestForm();
  }

  return {
  init: init
};
}());

$(function(){
  Airbo.SignupRequest.init();
});
