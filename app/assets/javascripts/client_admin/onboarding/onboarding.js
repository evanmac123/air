$(function() {
  if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".onboarding-body")) {
    Airbo.OnboardingSubnav.init();
    Airbo.UserOnboardingUpdate.init();
    Airbo.OnboardingModals.init();
    Airbo.OnboardingCreate.init();
    Airbo.UserOnboardingCreate.init();
  }
});
