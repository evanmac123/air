var Airbo = window.Airbo || {};

Airbo.OnboardingModals = (function(){

  function init() {
    $(".open-progress-modal").on("click", function() {
      $('#progress-modal').foundation('reveal', 'open');
    });

    $(".close-progress-modal").on("click", function() {
      $('#progress-modal').foundation('reveal', 'close');
    });
  }

  return {
    init: init
  };
}());
