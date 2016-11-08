var Airbo = window.Airbo || {};

Airbo.OnboardingKpis = (function(){
  function initializeOnboardingPing() {
    var id = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    Airbo.Utils.ping("Onboarding: Step 1", { id: id, email: email, kpi: "land on onboarding page" });
  }

  function selectPriorityPing() {
    var id = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    Airbo.Utils.ping("Onboarding: Step 2", { id: id, email: email, kpi: "selects priority" });
  }

  function completeTilePing() {
    var id = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    Airbo.Utils.ping("Onboarding: Step 3", { id: id, email: email, kpi: "completes tile" });
  }

  function viewsActivityDashboardPing() {
    var id = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    Airbo.Utils.ping("Onboarding: Step 4", { id: id, email: email, kpi: "views activity dashboard" });
  }

  function answersMoreInfoQuestionPing() {
    var id = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    Airbo.Utils.ping("Onboarding: Step 5", { id: id, email: email, kpi: "answers more info cta" });
  }

  function fullyConvertedPing() {
    var id = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    Airbo.Utils.ping("Onboarding: Step 6", { id: id, email: email, kpi: "fully converts to client admin" });
  }

  return {
    initializeOnboardingPing: initializeOnboardingPing,
    selectPriorityPing: selectPriorityPing,
    completeTilePing: completeTilePing,
    viewsActivityDashboardPing: viewsActivityDashboardPing,
    answersMoreInfoQuestionPing: answersMoreInfoQuestionPing,
    fullyConvertedPing: fullyConvertedPing,
  };
}());
