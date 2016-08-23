var Airbo = window.Airbo || {};

Airbo.Landing = (function(){
  function init() {
    $("a.topic").click(function() {
      var name = $(this).text();
      Airbo.Utils.ping("Viewed Priority", {priority: name, source: "Marketing Landing Page"});
    });
  }
  return {
  init: init
};
}());

$(function(){
  // so specific selectors because we have product page with old header
  if( $(".topics_section").length > 0 ){
    Airbo.Landing.init();
  }
});

$(document).ready(function() {
  $(".pre-signup").submit(function(e) {
    var enteredEmail = this.email.value;
    if ( /(.+)@(.+){2,}\.(.+){2,}/.test(enteredEmail) === false ) {
      e.preventDefault();
      if (enteredEmail.length === 0) {
        $(this.email).attr("placeholder", "Please enter a valid email");
      } else {
        $(this.email).css("color", "#E26A6A");
      }
    }
  });

  $(".pre-signup").keyup(function(e) {
    var enteredEmail = this.email.value;
      $(this.email).removeAttr("style");
  });

  var validCharactersRegex = /^[a-z][- a-z]*[- ]{1}[- a-z]*[a-z]$/i;
  function fullname_valid(value) {
      return validCharactersRegex.test(value);
  }

  $.validator.addMethod("custom_fullname", function(value, element) {
      return fullname_valid(value);
  }, "Please enter your first and last name.");


  $("#landing_info_request_form").submit(function(event){
    var form = $("#landing_info_request_form");
    var config={
      onkeyup: false,
      rules: {
        "request[company]": {
          required: true,
        },
        "request[email]": {
          required: true,
          email: true
        },
        "request[name]": {
          required: true,
          custom_fullname: true
        },
        "request[password]": {
          required: true,
          minlength: 6
        },
        "request[phone]": {
          required: true,
          phoneUS: true
        },
        "request[size]": {
          required: true,
        },
      },
      messages: {
        "request[company]": {
          required: "Please enter a company name.",
        },
        "request[name]": {
          required: "Please enter your first and last name.",
        },
        "request[email]": {
          required: "Please enter your work email.",
        },
        "request[phone]": {
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
});
