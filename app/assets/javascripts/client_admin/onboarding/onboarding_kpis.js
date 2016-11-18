var Airbo = window.Airbo || {};

Airbo.OnboardingKpis = (function(){
  var id;
  var email;
  var ip;
  var currentUser;

  function initializeOnboardingPing() {
    var properties = $.extend({ onboarding_id: id, onboarding_email: email, ip: ip}, currentUserData);
    Airbo.Utils.ping("Onboarding: Step 1", properties);
    debugger
  }

  function selectPriorityPing() {
    var properties = $.extend({ onboarding_id: id, onboarding_email: email, ip: ip}, currentUserData);
    Airbo.Utils.ping("Onboarding: Step 2", properties);
  }

  function completeTilePing() {
    var properties = $.extend({ onboarding_id: id, onboarding_email: email, ip: ip}, currentUserData);
    Airbo.Utils.ping("Onboarding: Step 3", properties);
  }

  function viewsActivityDashboardPing() {
    var properties = $.extend({ onboarding_id: id, onboarding_email: email, ip: ip}, currentUserData);
    Airbo.Utils.ping("Onboarding: Step 4", properties);
  }

  function answersMoreInfoQuestionPing() {
    var properties = $.extend({ onboarding_id: id, onboarding_email: email, ip: ip}, currentUserData);
    Airbo.Utils.ping("Onboarding: Step 5", properties);
  }

  function fullyConvertedPing() {
    var properties = $.extend({ onboarding_id: id, onboarding_email: email, ip: ip}, currentUserData);
    Airbo.Utils.ping("Onboarding: Step 6", properties);
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

$(function(){
  if( $(".onboarding-body").length > 0 ) {
    id    = $(".onboarding-body").data("id");
    email = $(".onboarding-body").data("email");
    ip    = $(".onboarding-body").data("ip");
    currentUser = $("body").data("currentUser");
  }
});
