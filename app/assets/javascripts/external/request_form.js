
var Airbo = window.Airbo || {};

Airbo.RequestForm = (function(){
  var formSel = "#request_form"
    , submitBtnSel = "#submit_request"
    , form
    , submitBtn
    , config
    , validator
  ;

  function initFormValidator(){
    var config={
      onkeyup: false,
      onfocusout: function(event){
        // validator.resetForm();
      },
      rules: {
        "demo_request[email]": {
          required: true,
          email: true
        }
      },
      errorPlacement: function(error, element) {
        error.insertBefore($(".greeting_after"));
        // $('html,body').animate({ scrollTop: $(document).height()}, 2000);
      }
    };

    config = $.extend({}, Airbo.Utils.validationConfig, config);
    validator = form.validate(config);
  }
  function showConfirmation(email){
    $(".err").hide();
    $(".greeting_after").fadeIn( 1000 );;
  }
  function initFormSubmit(){
    form.submit(function(event){
      event.preventDefault();
      if(form.valid()){
        $.post( $(this).attr("action"), form.serialize())
        .done(function(data, textStatus, jqXHR){
          showConfirmation(data.email);
          form[0].reset();
          validator.resetForm();
          // $('html,body').animate({ scrollTop: $(document).height()}, 2000);
        });
      }else{
        validator.focusInvalid();
        $(".greeting_after").hide();
      }
      $('html,body').animate({ scrollTop: $(document).height()}, 2000);
    });
  }
  function init(){
    form = $(formSel);
    submitBtn = $(submitBtnSel);
    initFormValidator();
    initFormSubmit();
  }
  return {
    init: init
  }
}());

$(function(){
  if( $("#request_form").length > 0 ){
    Airbo.RequestForm.init();
  }
});

