var Airbo = window.Airbo || {};

Airbo.OnboardingKpis = (function(){
  function selectPriorityPing() {
    Airbo.Utils.ping("Onboarding", { kpi: "selects priority", user_onboarding_id: $(".onboarding-body").data("id"), user_onboarding_state: $(".onboarding-body").data("state") });
  }

  function completeTilePing() {
    Airbo.Utils.ping("Onboarding", { kpi: "completes tile", user_onboarding_id: $(".onboarding-body").data("id"), user_onboarding_state: $(".onboarding-body").data("state") });
  }

  function viewsActivityDashboardPing() {
    Airbo.Utils.ping("Onboarding", { kpi: "views activity dashboard", user_onboarding_id: $(".onboarding-body").data("id"), user_onboarding_state: $(".onboarding-body").data("state") });
  }

  function answersMoreInfoQuestionPing(response) {
    Airbo.Utils.ping("Onboarding", { kpi: "answers more info cta", user_onboarding_id: $(".onboarding-body").data("id"), user_onboarding_state: $(".onboarding-body").data("state"),  response: response });
  }

  return {
    selectPriorityPing: selectPriorityPing,
    completeTilePing: completeTilePing,
    viewsActivityDashboardPing: viewsActivityDashboardPing,
    answersMoreInfoQuestionPing: answersMoreInfoQuestionPing
  };
}());
