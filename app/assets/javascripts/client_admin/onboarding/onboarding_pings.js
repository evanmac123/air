var Airbo = window.Airbo || {};

Airbo.OnboardingPings = (function(){
  function sharePing(id, state) {
    $("#share_airbo").click(function() {
      Airbo.Utils.ping("Onboarding: Share", { kpi: "share", user_onboarding_id: id, user_onboarding_state: state });
    });
  }

  function scheduleDemoPing(id, state) {
    $(".schedule-demo-button").click(function() {
      Airbo.Utils.ping("Onboarding: Schedule Demo", { kpi: "schedule demo", user_onboarding_id: id, user_onboarding_state: state });
    });
  }

  function init() {
    var id = $(".onboarding-body").data("id");
    var state = $(".onboarding-body").data("state");
    sharePing(id, state);
    scheduleDemoPing(id, state);
  }

  return {
    init: init,
  };
}());
