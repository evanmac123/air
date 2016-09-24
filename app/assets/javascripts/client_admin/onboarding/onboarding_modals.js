var Airbo = window.Airbo || {};

Airbo.OnboardingModals = (function(){

  function init() {
    $(".open-progress-modal").on("click", function() {
      $('#progress-modal').foundation('reveal', 'open', {
  animation: 'fadeAndPop',
  animation_speed: 25000});
    });

    $(".close-progress-modal").on("click", function() {
      $('#progress-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 25000});
    });
  }

  return {
    init: init
  };
}());
