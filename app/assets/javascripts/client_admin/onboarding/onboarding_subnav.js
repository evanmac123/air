var Airbo = window.Airbo || {};

Airbo.OnboardingSubnav = (function() {
  function init(){
    var state = $(".onboarding-body").data("state");
    if (state < 3) {
      $("#tile_manager_nav").hide();
    } else if (state < 4) {
      $("#tile_manager_nav").show();
      $("#share_airbo").hide();
    }
  }

  return {
    init: init
  };
})();
