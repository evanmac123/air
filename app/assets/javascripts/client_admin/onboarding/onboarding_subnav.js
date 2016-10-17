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

      $("#share_airbo i").removeClass("fa-share-alt");
      $("#share_airbo i").addClass("fa-lock");
      $("#share_airbo a").bind('click', false);
    } else if (state < 4) {
      $("#share_airbo i").removeClass("fa-share-alt");
      $("#share_airbo i").addClass("fa-lock");
      $("#share_airbo a").bind('click', false);
    }
  }

  return {
    init: init
  };
}());
