var Airbo = window.Airbo || {};

Airbo.UserOnboardingUpdate = (function() {
  function firstUpdate(id) {
    $(".tile_multiple_choice_answer").on("click", function() {
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { state: "second" } }),
        contentType: 'application/json', // format of request payload
        dataType: 'json', // format of the response
        success: function(res) {
          $(".progressbar li:nth-child(2)").addClass("active");
          $("#board_activity").show();
          return res;
        }
      });
    });
  }

  function secondUpdate(id) {
    $("#board_activity").on("click", function() {
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { state: "third" } }),
        contentType: 'application/json', // format of request payload
        dataType: 'json', // format of the response
        success: function(res) {
          return res;
        }
      });
    });
  }

  function init(){
    var id = $(".onboarding-body").data("id");
    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".first-user-onboarding-state")) {
      firstUpdate(id);
    }

    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".second-user-onboarding-state")) {
      secondUpdate(id);
    }
  }

  return {
    init: init
  };
})();



$(function(){
  if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".onboarding-body")) {
    Airbo.UserOnboardingUpdate.init();
  }
});
