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
    , demoModalSelector = "#schedule_demo_modal"
    , closeModalSelector = "#schedule_demo_modal .close-reveal-modal"
    , demoFormSelector =  "#schedule_demo_form"
    , demoRequestButtonSelector =  "#demo_request, .request_demo"
    , requestContentSelector = "#request_content"
    , confirmationContentSelector = "#confirmation_content"
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

  function initScheduleDemoModal(){
   demoRequestButton.click(function(event){
     event.preventDefault();
      modalPing("Source", "Top Nav");
      openModal();
    });

    demoModal.bind('closed.fndtn.reveal', function(){
      if( !localStorage.getItem("demoRequested") ){
        console.log(11);
        modalPing("Closed Modal", "Yes");
      }
    });
  }

  function openModal(){
    scrollPageToTop();
    prepareForm();
    demoModal.foundation("reveal", "open", {animation: "fade",closeOnBackgroundClick: true });
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

  function showConfirmation(){
   $("#confirmation_content").show();
   $("#request_content").hide();
  }

  function prepareForm(){
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
        .done(function(){
          showConfirmation();
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
    demoModal= $(demoModalSelector);
    demoRequestButton = $(demoRequestButtonSelector);
    demoModal = $(demoModalSelector);
    demoForm = $(demoFormSelector);
    requestContent = $(requestContentSelector);
    confirmationContent = $(confirmationContentSelector);
  }

  function initCloseOnBackgroundClick(){
    $(demoModalSelector).click(function(event){
      if($(event.target).is(demoModalSelector)){
        $(closeModalSelector).trigger("click");
      }
    });
  }

  function initSubmitAnother(){
    $(submitAnother).click(function(){
      prepareForm();
    })
  }

  function init(){
    initJQueryObjects();
    initScheduleDemoModal();
    initFormValidator();
    initFormSubmit();
    initCloseOnBackgroundClick();
    initSubmitAnother();
  }

  return {
    init: init,
    openModal: openModal,
    modalPing: modalPing,
    linkCopied: linkCopied
  }
}())
