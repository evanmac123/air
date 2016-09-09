var Airbo = window.Airbo || {};

Airbo.LandingModals = (function(){

  function init() {
    $('#signups_modal').foundation('reveal', 'open');
    $('#demo_requests_modal').foundation('reveal', 'open');
  }

  return {
    init: init
  };
}());
