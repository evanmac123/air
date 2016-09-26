var Airbo = window.Airbo || {};

Airbo.OnboardingSubnav = (function() {
  function init(){
    var state = $(".onboarding-body").data("state");
    if (state == "first") {
      $("#board_activity").hide();
      $("#share_airbo").hide();
    } else if (state == "second") {
      $("#share_airbo").hide();
    }
  }

  return {
    init: init
  };
})();
