var Airbo = window.Airbo || {};

Airbo.PublicBoardManager = (function(){

  var form, validator;

  function setupStickyHeaders(){
    // Sticky Header
    $(window).scroll(function() {

      if ($(window).scrollTop() > 300) {
        $('.main_h').addClass('sticky');
      } else {
        $('.main_h').removeClass('sticky');
      }
    });
    // Mobile Navigation
    $('.mobile-toggle').click(function() {
      if ($('.main_h').hasClass('open-nav')) {
        $('.main_h').removeClass('open-nav');
      } else {
        $('.main_h').addClass('open-nav');
      }
    });

    $('.main_h li a').click(function() {
      if ($('.main_h').hasClass('open-nav')) {
        $('.navigation').removeClass('open-nav');
        $('.main_h').removeClass('open-nav');
      }
    });

    // navigation scroll lijepo radi materem
    $('nav a').click(function(event) {
      var id = $(this).attr("href");
      var offset = 70;
      var target = $(id).offset().top - offset;
      $('html, body').animate({
        scrollTop: target
      }, 500);
      event.preventDefault();
    });
  }

  function initScheduleDemoModal(){
    $("#demo_request").click(function(){
      $("#schedule_demo_modal").foundation("reveal", "open", {animation: "fade",closeOnBackgroundClick: true });
    });
  }

  function initFormValidator(){
    form = $("#schedule_demo_form")
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
      // var form= $(this);
      if(form.valid()){
        $.post( $(this).attr("action"), form.serialize())
        .done(function(){
          showConfirmation();
        });
      }else{
        validator.focusInvalid();
      }
    });

  }

  function init(){
    setupStickyHeaders();
    initScheduleDemoModal();
    initFormValidator();
    initFormSubmit();
  }

  return {
    init: init
  }
}());

$(function(){
  Airbo.PublicBoardManager.init();
});
