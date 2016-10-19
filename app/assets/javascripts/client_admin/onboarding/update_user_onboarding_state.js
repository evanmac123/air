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
            $(".progress-step-header").text("You've completed 3 steps out of 4");
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
  }

  function finalCta(id) {
    $("#complete-yes-more-info").on("click", function() {
      Airbo.OnboardingKpis.answersMoreInfoQuestionPing("yes");
      $(".onboarding-complete-modal").foundation('reveal', 'close');
      $('#loading-full-airbo-modal').foundation('reveal', 'open');
      $('#loading-full-airbo-modal').css("top", "40%");
      $.ajax({
        type: "PUT",
        url: "/api/v1/user_onboardings/" + id,
        data: JSON.stringify({ user_onboarding: { completed: true, more_info: "yes" } }),
        contentType: 'application/json',
        dataType: 'json',
        success: function(res) {
          window.location = "/client_admin/tiles";
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

    finalCta(id);
  }

  return {
    init: init,
    thirdUpdate: thirdUpdate
  };
})();
