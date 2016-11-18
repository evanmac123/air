var Airbo = window.Airbo || {};

Airbo.OnboardingKpis = (function(){
  function initializeOnboardingPing() {
    var properties = mixpanelData();
    Airbo.Utils.ping("Onboarding: Step 1", properties);
  }

  function selectPriorityPing() {
    var properties = mixpanelData();
    Airbo.Utils.ping("Onboarding: Step 2", properties);
  }

  function completeTilePing() {
    var properties = mixpanelData();
    Airbo.Utils.ping("Onboarding: Step 3", properties);
  }

  function viewsActivityDashboardPing() {
    var properties = mixpanelData();
    Airbo.Utils.ping("Onboarding: Step 4", properties);
  }

  function answersMoreInfoQuestionPing() {
    var properties = mixpanelData();
    Airbo.Utils.ping("Onboarding: Step 5", properties);
  }

  function fullyConvertedPing() {
    var properties = mixpanelData();
    Airbo.Utils.ping("Onboarding: Step 6", properties);
  }

  function mixpanelData() {
    var id    = $(".onboarding-body").data("id");
    var email = $(".onboarding-body").data("email");
    var ip    = $(".onboarding-body").data("ip");
    var currentUser = $("body").data("currentUser");
    return $.extend({ onboarding_id: id, onboarding_email: email, ip: ip}, currentUser);
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
