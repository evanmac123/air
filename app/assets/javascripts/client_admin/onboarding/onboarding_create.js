var Airbo = window.Airbo || {};

Airbo.OnboardingCreate = (function() {
  function createOnboarding(){
    $(".topic-board").on("click", function() {
      var self = $(this);
      var form = $("#onboarding-form");
      $("#topic_board_id").val(self.data("board-id"));
      $(".onboarding-new").hide();
      $('#customizing-airbo-modal').foundation('reveal', 'open');

      $.post(form.attr("action"), form.serialize()).done(
        function(data, status, xhr) {
          Airbo.CookieMonster.setCookie("user_onboarding", data.hash);
          Airbo.Utils.ping("Activity Session - New", data.user);
          if ( data.user_onboarding ) {
            window.location.href = xhr.getResponseHeader("location");
          } else {
            $(".onboarding-new").show();
            $('#customizing-airbo-modal').foundation('reveal', 'close');
          }
        }
      );
    });
  }

  function init() {
    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".onboardings-new")) {
      createOnboarding();
    }
  }

  return {
    init: init
  };
}());
