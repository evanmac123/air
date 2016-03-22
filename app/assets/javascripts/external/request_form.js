
var Airbo = window.Airbo || {};

Airbo.RequestForm = (function(){
  var formSel = "#request_form"
    , submitBtnSel = "#submit_request"
    , successBtnSel = ".success"
    , form
    , submitBtn
    , config
    , validator
    , linkToFormSel = ".scroll_to_demo"
  ;

  function ping() {
    Airbo.Utils.ping("New Lead", {"action": "Submitted Email - v. 3.17.16", page_name: window.location.pathname});
  }

  function scrollToBottom() {
    $('html,body').animate({ scrollTop: $(document).height()}, 2000);
  }

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
    successState()
  }

  function successState(){
    submitBtn.hide();
    $("#demo_request_email").prop("disabled",true).addClass("disabled")
    successBtn.removeClass("hidden").css("width", submitBtn.outerWidth());
  }

  function initFormSubmit(){

    form.submit(function(event){
      event.preventDefault();
      if(form.valid()){
        $.post( $(this).attr("action"), form.serialize())
        .done(function(data, textStatus, jqXHR){

          showConfirmation(data.email);
          //form[0].reset();
          validator.resetForm();
          ping();
          // $('html,body').animate({ scrollTop: $(document).height()}, 2000);
        });
      }else{
        validator.focusInvalid();
        $(".greeting_after").hide();
      }
      //scrollToBottom();
    });
  }
  function initEvents() {
    $(linkToFormSel).click(function(e){
      e.preventDefault();
      scrollToBottom();
    });
    // $(window).scroll(function() {
    //   var pageBottom = $(document).height() - $(window).height();
    //   if ($(window).scrollTop() < pageBottom - 150) {
    //     $('.request_form_section').addClass('sticky');
    //   } else {
    //     $('.request_form_section').removeClass('sticky');
    //   }
    // });
  }
  function init(){
    form = $(formSel);
    submitBtn = $(submitBtnSel);
    successBtn = $(successBtnSel);
    initFormValidator();
    initFormSubmit();
    initEvents();
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

