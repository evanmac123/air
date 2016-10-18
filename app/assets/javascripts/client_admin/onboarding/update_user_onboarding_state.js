var Airbo = window.Airbo || {};

Airbo.UserOnboardingUpdate = (function() {
  function secondUpdate(id) {
    $(".tile_multiple_choice_answer").on("click", function() {
      Airbo.OnboardingKpis.completeTilePing();
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { state: 3 } }),
        contentType: 'application/json',
        dataType: 'json',
        success: function(res) {
          setTimeout(function() {
            $("#board_activity i").addClass("fa-line-chart");
            $("#board_activity i").removeClass("fa-lock");
            $("#board_activity a").unbind('click', false);

            $(".progress-bar-label span").text("Tour Progress (3/4)");
            $(".onboarding-progress-bar .meter").css("width", "75%");
            $($(".progress-steps").children()[3]).addClass("complete");
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
        contentType: 'application/json',
        dataType: 'json',
        success: function(res) {
          $(".progress-bar-label span").text("Tour Progress (4/4)");
          $(".onboarding-progress-bar .meter").css("width", "100%");
          $($(".progress-steps").children()[4]).addClass("complete");

          return res;
        }
      });
    });
  }

  function finalCta(id) {
    $("#complete-yes-more-info").on("click", function() {
      Airbo.OnboardingKpis.answersMoreInfoQuestionPing("yes");
      Intercom('show');
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { more_info: "yes" } }),
        contentType: 'application/json',
        dataType: 'json',
        success: function(res) {
          return res;
        }
      });
    });

    $("#complete-no-more-info").on("click", function() {
      Airbo.OnboardingKpis.answersMoreInfoQuestionPing("no");
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { more_info: "no" } }),
        contentType: 'application/json',
        dataType: 'json',
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

    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(".user-onboarding-state-4")) {
      finalCta(id);
    }
  }

  return {
    init: init
  };
})();
