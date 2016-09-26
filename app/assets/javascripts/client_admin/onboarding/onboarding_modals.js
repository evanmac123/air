var Airbo = window.Airbo || {};

Airbo.OnboardingModals = (function(){

  function init() {
    $(".open-progress-modal").on("click", function() {
      $('#progress-modal').foundation('reveal', 'open', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    $(".close-progress-modal").on("click", function() {
      $('#progress-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    $(".schedule-demo-button").on("click", function() {
      $.post("/api/v1/email_info_requests", $("#demo-request-form").serialize());
      $('#schedule-demo-modal').foundation('reveal', 'open', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    $(".close-demo-button").on("click", function() {
      $('#schedule-demo-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });
  }

  return {
    init: init
  };
}());
