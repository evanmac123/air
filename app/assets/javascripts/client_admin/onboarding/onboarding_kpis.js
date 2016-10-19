var Airbo = window.Airbo || {};

Airbo.OnboardingKpis = (function(){
  function initializeOnboardingPing() {
    Airbo.Utils.ping("Onboarding: Step 1", { kpi: "land on onboarding page" });
  }

  function selectPriorityPing() {
    Airbo.Utils.ping("Onboarding: Step 2", { kpi: "selects priority" });
  }

  function completeTilePing() {
    Airbo.Utils.ping("Onboarding: Step 3", { kpi: "completes tile" });
  }

  function viewsActivityDashboardPing() {
    Airbo.Utils.ping("Onboarding: Step 4", { kpi: "views activity dashboard" });
  }

  function answersMoreInfoQuestionPing() {
    Airbo.Utils.ping("Onboarding: Step 5", { kpi: "answers more info cta" });
  }

  function fullyConvertedPing() {
    Airbo.Utils.ping("Onboarding: Step 6", { kpi: "fully converts to client admin" });
  }

  return {
    selectPriorityPing: selectPriorityPing,
    completeTilePing: completeTilePing,
    viewsActivityDashboardPing: viewsActivityDashboardPing,
    answersMoreInfoQuestionPing: answersMoreInfoQuestionPing,
    fullyConvertedPing: fullyConvertedPing
  };
}());
