var Airbo = window.Airbo || {};

Airbo.PublicBoardManager = (function(){

  var form, validator;

  function setupStickyHeaders(){
    $(window).scroll(function() {
      if ($(window).scrollTop() > $(".user_container").position().top) {
        $('.main_h').addClass('sticky');
      } else {
        $('.main_h').removeClass('sticky');
      }
    });

    $('.row_nav').click(function(event) {
      $('html, body').animate({
       scrollTop: 0
      }, 500);
    });
  }

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
    $("#demo_request").click(function(){
      modalPing("Source", "Top Nav");
      openModal();
    });

    $("#schedule_demo_modal").bind('closed.fndtn.reveal', function(){
      if( !localStorage.getItem("demoRequested") ){
        console.log(11);
        modalPing("Closed Modal", "Yes");
      }
    });
  }

  function openModal(){
    $("#schedule_demo_modal").foundation("reveal", "open", {animation: "fade",closeOnBackgroundClick: true });
  }

  function initFormValidator(){
    form = $("#schedule_demo_form");
    var config={
      rules: {
        "demo_request[email]": {
          required: true,
          email: true
        }
      }};

      config = $.extend({}, Airbo.Utils.validationConfig, config);
      validator = form.validate(config);
  }

  function showConfirmation(){
   $("#confirmation_content").show();
   $("#request_content").hide();
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

  function init(){
    setupStickyHeaders();
    initScheduleDemoModal();
    initFormValidator();
    initFormSubmit();
  }

  return {
    init: init,
    openModal: openModal,
    modalPing: modalPing,
    linkCopied: linkCopied
  }
}());

$(function(){
  Airbo.PublicBoardManager.init();
  Airbo.Utils.TextSelectionDector.init("#link_for_copy", Airbo.PublicBoardManager.linkCopied);
});
