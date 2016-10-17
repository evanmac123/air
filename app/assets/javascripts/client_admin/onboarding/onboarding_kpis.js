var Airbo = window.Airbo || {};

Airbo.OnboardingKpis = (function(){
  function selectPriorityPing(id, state) {
    Airbo.Utils.ping("Onboarding", { kpi: "selects priority", user_onboarding_id: id, user_onboarding_state: state });
  }

  function completeTilePing(id, state) {
    Airbo.Utils.ping("Onboarding", { kpi: "completes tile", user_onboarding_id: id, user_onboarding_state: state });
  }

  function viewsActivityDashboardPing(id, state) {
    Airbo.Utils.ping("Onboarding", { kpi: "views activity dashboard", user_onboarding_id: id, user_onboarding_state: state });
  }

  function answersMoreInfoQuestionPing(id, state, response) {
    Airbo.Utils.ping("Onboarding", { kpi: "answers more info cta", user_onboarding_id: id, user_onboarding_state: state,  response: response });
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
