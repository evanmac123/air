var Airbo = window.Airbo || {};

Airbo.OnboardingKpis = (function(){
  function initializeOnboardingPing() {
    var properties = onboardingMixpanelData(1, "lands on onboarding");
    Airbo.Utils.ping("Onboarding", properties);
  }

  function selectPriorityPing() {
    var properties = onboardingMixpanelData(2, "selects priority");
    Airbo.Utils.ping("Onboarding", properties);
  }

  function completeTilePing() {
    var properties = onboardingMixpanelData(3, "completes tile");
    Airbo.Utils.ping("Onboarding", properties);
  }

  function viewsActivityDashboardPing() {
    var properties = onboardingMixpanelData(4, "views activity dashboard");
    Airbo.Utils.ping("Onboarding", properties);
  }

  function answersMoreInfoQuestionPing() {
    var properties = onboardingMixpanelData(5, "answers more info cta");
    Airbo.Utils.ping("Onboarding", properties);
  }

  function fullyConvertedPing() {
    var properties = onboardingMixpanelData(6, "fully converts to client admin");
    Airbo.Utils.ping("Onboarding", properties);
  }

  function onboardingMixpanelData(step, kpi) {
    var id    = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    var ip    = $(".onboarding-body").data("ip");
    var currentUser = $("body").data("currentUser");
    return $.extend({ onboarding_id: id, onboarding_email: email, ip_address: ip, step: step, kpi: kpi }, currentUser);
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
