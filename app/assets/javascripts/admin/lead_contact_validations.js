var Airbo = window.Airbo || {};

Airbo.LeadContactValidations = (function(){
  function initDenialValidations() {
    $("#deny-lead-contact").on("click", function(event) {
      var form = $(this).parent();
      var config = {
        onkeyup: false,
        rules: {
          "lead_contact[name]": {
            required: true,
          },
          "lead_contact[email]": {
            required: true,
            email: true
          },
        },
        messages: {
          "request[name]": {
            required: "Please enter a first and last name.",
          },
          "request[email]": {
            required: "Please enter an email.",
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
        $("#lead_contact_matched_organization").prop('readonly', true);
      }
    });
  }

  function initApproveValidations() {
    $("#approve-lead-contact").on("click", function(event) {
      $("#lead_contact_matched_organization").prop('readonly', false);

      var validCharactersRegex = /^[a-z][- a-z]*[- ]{1}[- a-z]*[a-z]$/i;
      function fullname_valid(value) {
          return validCharactersRegex.test(value);
      }

      $.validator.addMethod("custom_fullname", function(value, element) {
          return fullname_valid(value);
      }, "Please enter a first and last name.");

      var form = $(this).parent();
      var config = {
        onkeyup: false,
        rules: {
          "lead_contact[matched_organization]": {
            required: true,
            minlength: 2
          },
          "lead_contact[name]": {
            required: true,
            custom_fullname: true
          },
          "lead_contact[email]": {
            required: true,
            email: true
          },
          "lead_contact[phone]": {
            required: true,
            phoneUS: true
          },
          "lead_contact[organization_name]": {
            required: true,
          },
        },
        messages: {
          "lead_contact[matched_organization]": {
            required: "Select and existing organization before approval.",
          },
          "lead_contact[organization_name]": {
            required: "Please either match an organization name or, if the organization is new, enter the new organization name.",
          },
          "lead_contact[name]": {
            required: "Please enter a first and last name.",
          },
          "lead_contact[email]": {
            required: "Please enter an email.",
          },
          "lead_contact[phone]": {
            required: "Please enter a phone number. If the number is invalid, please enter 000-000-0000.",
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
        $("#lead_contact_matched_organization").prop('readonly', true);
      }
    });
  }

  function initProcessValidations() {
    $("#process-lead-contact").on("click", function(event) {
      function fullname_valid(value) {
        var validCharactersRegex = /^[a-z][- a-z]*[- ]{1}[- a-z]*[a-z]$/i;
        return validCharactersRegex.test(value);
      }

      function valid_board_name(value, element) {
        var board_names = JSON.parse($('#board_names').val());
        return !board_names.includes(value);
      }

      $.validator.addMethod("custom_fullname", function(value, element) {
          return fullname_valid(value);
      }, "Please enter a first and last name.");

      $.validator.addMethod("board_name_taken", function(value, element) {
          return valid_board_name(value);
      }, "This board name is already taken.");


      var form = $(".edit_lead_contact");
      var config = {
        onkeyup: false,
        rules: {
          "lead_contact[name]": {
            required: true,
            custom_fullname: true
          },
          "lead_contact[email]": {
            required: true,
            email: true
          },
          "lead_contact[phone]": {
            required: true,
            phoneUS: true
          },
          "board[board_template]": {
            required: true,
          },
          "board[name]": {
            required: true,
            board_name_taken: true
          },
          "board[custom_reply_email_name]": {
            required: true,
          },
        },
        messages: {
          "lead_contact[matched_organization]": {
            required: "Select and existing organization before approval.",
          },
          "lead_contact[name]": {
            required: "Please enter a first and last name.",
          },
          "lead_contact[email]": {
            required: "Please enter an email.",
          },
          "lead_contact[phone]": {
            required: "Please enter a phone number. If the number is invalid, please enter 000-000-0000.",
          },
          "board[board_template]": {
            required: "Please select a board template.",
          },
          "board[name]": {
            required: "Please enter a board name.",
            remote: "This board name has already been taken."
          },
          "board[custom_reply_email_name]": {
            required: "Please enter a custom name that will be the 'from' name in board emails.",
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
      } else {
        $(".button-copy").hide();
        $("#processing-lead-spinner").show();
      }
    });
  }

  function init() {
    initApproveValidations();
    initDenialValidations();
    initProcessValidations();
  }

  return {
    init: init
  };
}());

$(function(){
  Airbo.LeadContactValidations.init();
});
