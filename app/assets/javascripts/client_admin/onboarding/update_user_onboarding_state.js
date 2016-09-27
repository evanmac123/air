var Airbo = window.Airbo || {};

Airbo.UserOnboardingUpdate = (function() {
  function secondUpdate(id) {
    $(".tile_multiple_choice_answer").on("click", function() {
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { state: 3 } }),
        contentType: 'application/json', // format of request payload
        dataType: 'json', // format of the response
        success: function(res) {
          $("#tile_manager_nav").show();
          $("#share_airbo").hide();
          return res;
        }
      });
    });
  }

  function thirdUpdate(id) {
    $("#board_activity").on("click", function() {
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { state: 4 } }),
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
    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".user-onboarding-state-2")) {
      secondUpdate(id);
    }

    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".user-onboarding-state-3")) {
      thirdUpdate(id);
    }
  }

  return {
    init: init
  };
})();
