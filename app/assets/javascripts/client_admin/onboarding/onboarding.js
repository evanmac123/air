$(function() {
  if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".onboarding-body")) {
    $(".grid_types").hide();
    Airbo.OnboardingSubnav.init();
    Airbo.UserOnboardingUpdate.init();
    Airbo.OnboardingModals.init();
    Airbo.OnboardingCreate.init();
    Airbo.UserOnboardingCreate.init();
    Airbo.OnboardingPings.init();
  }

  if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".onboardings-new")) {
    $("#logo a").removeAttr("href");
  }

  if (Airbo.Utils.supportsFeatureByPresenceOfSelector("#onboarding-to-full-client-admin")) {
    $("#onboarding-to-full-client-admin").on("click", function() {
      Airbo.Utils.Modals.close("#from-onboarding-modal");
      openIntercom();
    });
  }
});
