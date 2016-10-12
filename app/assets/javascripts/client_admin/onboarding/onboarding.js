var Airbo = window.Airbo || {};

Airbo.Onboarding = (function(){

  function init(){
    $(".topic-board").on("click", function() {
      var self = $(this);
      var form = $("#onboarding-form");
      $("#topic_board_id").val(self.data("board-id"));
      $(".onboarding-new").hide()
      $('#customizing-airbo-modal').foundation('reveal', 'open');

      $.post(form.attr("action"), form.serialize()).done(function(data, status, xhr) {
        Airbo.CookieMonster.setCookie("user_onboarding", data["hash"]);
        Airbo.Utils.ping("Activity Session - New", data["user"]);
        if (data["user_onboarding"]) {
          window.location.href = xhr.getResponseHeader("location");
        } else {
          $(".onboarding-new").show()
          $('#customizing-airbo-modal').foundation('reveal', 'close');
        }
      });
    })
  }

  return {
    init: init,
  };
}());



$(function() {

  if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".onboarding-body")) {
    Airbo.Onboarding.init();
    $(".total_employee_visits").hide();
    Airbo.OnboardingSubnav.init();
    Airbo.UserOnboardingUpdate.init();
    Airbo.OnboardingModals.init();
  }
});
