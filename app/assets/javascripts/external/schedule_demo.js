
var Airbo = window.Airbo || {};

Airbo.ScheduleDemoModal = (function(){
  var form
    , validator
    , demoRequestButton
    , demoModal
    , demoForm
    , requestContent
    , confirmationContent
    , submitAnother
    , submitAnotherSelector= "#submit_another"
    , demoModalId = "schedule_demo_modal"
    , demoFormSelector =  "#schedule_demo_form"
    , demoRequestButtonSelector =  "#demo_request, .request_demo"
    , requestContentSelector = "#request_content"
    , confirmationContentSelector = "#confirmation_content"
    , modalObj = Airbo.Utils.StandardModal()
  ;

  function modalPing(action, option){
    $.post("/ping", {
      event: 'Viewed HRM CTA Modal',
      properties: {
        action: action,
        option: option
      }
    });
  }

  function closeModalAfterRequestPing() {
    if( !localStorage.getItem("demoRequested") ){
      modalPing("Closed Modal", "Yes");
    }
  }

  function initScheduleDemoModal(){
   demoRequestButton.click(function(event){
     event.preventDefault();
      modalPing("Source", "Top Nav");
      openModal();
    });
  }

  function openModal(){
    scrollPageToTop();
    prepareForm();
    modalObj.open();
    $.post("/guest_user_reset/saw_modal");
  }


  function scrollPageToTop(){
    $('html,body').animate({ scrollTop: 0}, 5);
  }

  function initFormValidator(){
    form = $("#schedule_demo_form");
    var config={
      onkeyup: false,
      onfocusout: function(event){
        validator.resetForm();
      },
      rules: {
        "demo_request[email]": {
          required: true,
          email: true
        }
      }
    };

      config = $.extend({}, Airbo.Utils.validationConfig, config);
      validator = form.validate(config);
  }

  function showConfirmation(email){
   $("#confirmation_email").text(email);
   $("#confirmation_content").show();
   $("#request_content").hide();
  }

  function prepareForm(){
   //FIXME there is no form here. So this codes throws an exception
    form[0].reset();
    validator.resetForm();
    $("#request_content").show();
    $("#confirmation_content").hide();
  }

  function initFormSubmit(){

    $("#schedule_demo_form").submit(function(event){
      event.preventDefault();
      if(form.valid()){
        localStorage.setItem("demoRequested", true);
        $.post( $(this).attr("action"), form.serialize())
        .done(function(data, textStatus, jqXHR){
          showConfirmation(data.email);
        });
      }else{
        validator.focusInvalid();
      }
    });

  }

  function linkCopied(){
    modalPing("Copied Share Link");
  }

  function initJQueryObjects(){
    submitAnother= $(submitAnotherSelector);
    demoRequestButton = $(demoRequestButtonSelector);
    demoModal = $("#" + demoModalId);
    demoForm = $(demoFormSelector);
    requestContent = $(requestContentSelector);
    confirmationContent = $(confirmationContentSelector);
  }

  function initSubmitAnother(){
    $(submitAnother).click(function(){
      prepareForm();
    })
  }

  function initModalObj() {
    modalObj.init({
      modalId: demoModalId,
      onClosedEvent: closeModalAfterRequestPing,
      smallModal: true
    });
  }

  function init(){
    initModalObj();
    initJQueryObjects();
    initScheduleDemoModal();
    initFormValidator();
    initFormSubmit();
    initSubmitAnother();
  }

  return {
    init: init,
    openModal: openModal,
    modalPing: modalPing,
    linkCopied: linkCopied
  }
}());
