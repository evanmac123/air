var Airbo = window.Airbo || {};

Airbo.OnboardingKpis = (function(){
  function selectPriorityPing() {
    Airbo.Utils.ping("Onboarding: Step 1", { kpi: "selects priority", user_onboarding_id: $(".onboarding-body").data("id"), user_onboarding_state: $(".onboarding-body").data("state") });
  }

  function completeTilePing() {
    Airbo.Utils.ping("Onboarding: Step 2", { kpi: "completes tile", user_onboarding_id: $(".onboarding-body").data("id"), user_onboarding_state: $(".onboarding-body").data("state") });
  }

  function viewsActivityDashboardPing() {
    Airbo.Utils.ping("Onboarding: Step 3", { kpi: "views activity dashboard", user_onboarding_id: $(".onboarding-body").data("id"), user_onboarding_state: $(".onboarding-body").data("state") });
  }

  function answersMoreInfoQuestionPing(response) {
    Airbo.Utils.ping("Onboarding: Step 4", { kpi: "answers more info cta", user_onboarding_id: $(".onboarding-body").data("id"), user_onboarding_state: $(".onboarding-body").data("state"),  response: response });
  }

  function fullyConvertedPing() {
    Airbo.Utils.ping("Onboarding: Step 5", { kpi: "fully converts to client admin" });
  }

  return {
    selectPriorityPing: selectPriorityPing,
    completeTilePing: completeTilePing,
    viewsActivityDashboardPing: viewsActivityDashboardPing,
    answersMoreInfoQuestionPing: answersMoreInfoQuestionPing,
    fullyConvertedPing: fullyConvertedPing
  };
}());
