$(function() {
  if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".onboarding-body")) {
    $(".total_employee_visits").hide();
    Airbo.OnboardingSubnav.init();
    Airbo.UserOnboardingUpdate.init();
    Airbo.OnboardingModals.init();
  }
});
