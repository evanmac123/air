var Airbo = window.Airbo || {};

Airbo.OnboardingSubnav = (function() {
  function init(){
    var state = $(".onboarding-body").data("state");

    if (state > 1) {
      $("#tile_manager_nav").show();
    }

    if (state < 3) {
      $("#board_activity i").removeClass("fa-line-chart");
      $("#board_activity i").addClass("fa-lock");
      $("#board_activity a").bind('click', false);
    }
  }

  return {
    init: init
  };
}());
