var Airbo = window.Airbo || {};

Airbo.OnboardingModals = (function(){

  function init() {
    $('#progress-modal').foundation('reveal', 'open');
  }

  return {
    init: init
  };
}());
