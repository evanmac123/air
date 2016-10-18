var Airbo = window.Airbo || {};

Airbo.OnboardingPings = (function(){
  function intercomPing(id, state) {
    $("#contact_us").click(function() {
      Airbo.Utils.ping("Onboarding", { kpi: "intercom", user_onboarding_id: id, user_onboarding_state: state });
    });
  }

  function sharePing(id, state) {
    $("#share_airbo").click(function() {
      Airbo.Utils.ping("Onboarding", { kpi: "share", user_onboarding_id: id, user_onboarding_state: state });
    });
  }

  function scheduleDemoPing(id, state) {
    $(".schedule-demo-button").click(function() {
      Airbo.Utils.ping("Onboarding", { kpi: "schedule demo", user_onboarding_id: id, user_onboarding_state: state });
    });
  }

  function init() {
    var id = $(".onboarding-body").data("id");
    var state = $(".onboarding-body").data("state");
    intercomPing(id, state);
    sharePing(id, state);
    scheduleDemoPing(id, state);
  }

  return {
    init: init,
  };
}());
