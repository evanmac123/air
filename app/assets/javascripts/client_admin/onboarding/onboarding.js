$(function(){
  if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".onboarding-body")) {
    var state = $(".onboarding-body").data("state");
    var id = $(".onboarding-body").data("id");

    if (id) {
      $("#logo").children().prop("href", "/myairbo/" + id);
    } else {
      $("#logo").children().prop("href", "#");
    }

    Airbo.OnboardingSubnav.init();
    Airbo.UserOnboardingUpdate.init();
    Airbo.OnboardingModals.init();
  }
});
