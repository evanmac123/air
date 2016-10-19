var Airbo = window.Airbo || {};

Airbo.UserOnboardingCreate = (function() {
  function createOnboarding(){
    $(".accept-invite").on("click", function() {
      var self = $(this);
      var form = $("#user-onboarding-form");
      $(".user-onboarding-new").hide();
      $('#customizing-airbo-modal').foundation('reveal', 'open');

      $.post(form.attr("action"), form.serialize()).done(
        function(data, status, xhr) {
          Airbo.CookieMonster.setCookie("user_onboarding", data.hash);

          if ( data.user_onboarding ) {
            window.location.href = xhr.getResponseHeader("location");
          } else {
            $(".user-onboarding-new").show();
            $('#customizing-airbo-modal').foundation('reveal', 'close');
          }
        }
      );
    });
  }

  function init() {
    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".user_onboardings-new")) {
      createOnboarding();
    }
  }

  return {
    init: init
  };
}());
