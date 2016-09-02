
var Airbo = window.Airbo || {};

Airbo.RequestForm = (function(){
  var formSel = "#request_form"
    , submitBtnSel = "#submit_request"
    , successFlagSel = ".flag.green"
    , successBtn
    , successFlag
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
    var txt = $("footer #request_form .greeting_after").text();
    if($("#request_form").parents("footer").length == 0){
      $("#request_form .info").fadeIn( 1000 );;
    }else{

      $("#cta_label").text(txt);
    }
    swapFlagAndButton()
  }

  function swapFlagAndButton(){
    var w = submitBtn.outerWidth();
    submitBtn.hide();
    $("#demo_request_email").prop("disabled",true).addClass("disabled")
    successFlag.css("width",w ).removeClass("hidden");
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
        $(".info").hide();
      }
      //scrollToBottom();
    });
  }
  function initEvents() {
    $(linkToFormSel).click(function(e){
      e.preventDefault();
      scrollToBottom();
    });

  }
  function init(){
    form = $(formSel);
    submitBtn = $(submitBtnSel);
    successFlag = $(successFlagSel);
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
