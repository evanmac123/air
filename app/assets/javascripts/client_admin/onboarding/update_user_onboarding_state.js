var Airbo = window.Airbo || {};

Airbo.UserOnboardingUpdate = (function() {

  function init(){
    $(".right_multiple_choice_answer").on("click", function() {
      
    });
  }

  return {
    init: init
  };
});



$(function(){
  if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".first-user-onboarding-state")) {
    Airbo.UserOnboardingUpdate.init();
  }
});
