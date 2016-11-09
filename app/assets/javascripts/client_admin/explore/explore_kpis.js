var Airbo = window.Airbo || {};

Airbo.ExploreKpis = (function(){
  function initializeSomePing() {
    var id = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    Airbo.Utils.ping("Onboarding: Step 1", { id: id, email: email, kpi: "land on onboarding page" });
  }

  return {
    initializeOnboardingPing: initializeOnboardingPing,

  };
}());
