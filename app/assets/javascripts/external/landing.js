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
}
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


  $("#landing_sign_up_form").submit(function(event){
    var form = $("#landing_sign_up_form");
    var config={
      onkeyup: false,
      rules: {
        "user[email]": {
          required: true,
          email: true
        },
        "user[name]": {
          required: true,
        },
        "user[password]": {
          required: true,
        },
        "board[name]": {
          required: true,
        },
        "board[size]": {
          required: true,
        }
      }
    };

    config = $.extend({}, Airbo.Utils.validationConfig, config);
    var validator = form.validate(config);

    if(!form.valid()){
      event.preventDefault();
      validator.focusInvalid();
      validator.resetForm();
    }
  });
});
