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
          setTimeout(function() {
            $("#share_airbo").hide();
            $("#tile_manager_nav").fadeIn("slow", function() {
            });
            $(".progress-bar-label span").text("Get started (3/5)");
            $(".onboarding-progress-bar .meter").css("width", "60%");
            $($(".progress-steps").children()[2]).addClass("complete");
            $('#activity-modal').foundation('reveal', 'open', {
              animation: 'fadeAndPop',
              animation_speed: 350});
            return res;
          }, 1000);
        }
      });
    });
  }

  function thirdUpdate(id) {
    $(".close-viewed-activity-modal-button").on("click", function() {
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { state: 4 } }),
        contentType: 'application/json', // format of request payload
        dataType: 'json', // format of the response
        success: function(res) {
          $(".progress-bar-label span").text("Get started (4/5)");
          $(".onboarding-progress-bar .meter").css("width", "80%");
          $($(".progress-steps").children()[3]).addClass("complete");
          $($(".progress-steps").children()[4]).removeClass("locked");
          $("#tile_manager_nav #share_airbo").show();
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
