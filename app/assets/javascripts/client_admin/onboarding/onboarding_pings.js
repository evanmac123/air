var Airbo = window.Airbo || {};

Airbo.OnboardingPings = (function(){
  function intercomPing(id, state) {
    $("#contact_us").click(function() {
      Airbo.Utils.ping("Onboarding", { metric: "intercom", user_onboarding_id: id, user_onboarding_state: state });
    });
  }

  function init() {
    var id = $(".onboarding-body").data("id");
    var state = $(".onboarding-body").data("state");
    intercomPing(id, state);
  }

  return {
    init: init,
  };
}());
