var Airbo = window.Airbo || {};

Airbo.OnboardingModals = (function(){

  function init() {
    var state = $(".onboarding-body").data("state");
    var id = $(".onboarding-body").data("id");
    var demoScheduled = $(".onboarding-body").data("demo-scheduled");

    if (state == 3 & $(".user_onboardings-activity").length === 0) {
      //noop
    }

    $(".open-progress-modal").on("click", function() {
      triggerModal('#progress-modal', 'open');
    });

    $(".schedule-demo-button").on("click", function() {
      if (demoScheduled !== true && id !== "") {
        $.post("/api/v1/email_info_requests", $("#demo-request-form").serialize());
        $.ajax({
          type: "PUT",
          url: "/api/v1/user_onboardings/" + id,
          data: JSON.stringify({ user_onboarding: { demo_scheduled: true } }),
          contentType: 'application/json', // format of request payload
          dataType: 'json',
          success: function(res) {
            $(".onboarding-body").attr("data-demo-scheduled", "false");
            return res;
          }
        });
      }
      triggerModal('#schedule-demo-modal', 'open');
    });

    $(".close-board-view-button").on("click", function() {
      triggerModal('#board-view-modal', 'close');
      if(state == 2){
        Airbo.FirstTileHint.init({ showButtons:false});
      }
    });

    if (state == 2 && $("#tile_wall").length > 0) {
      setTimeout(function() {
        triggerModal('#board-view-modal', 'open');
      }, 1000);
    }

    if (state == 2 && $(".tile_main").length > 0) {
      setTimeout(function() {
        triggerModal('#tile-view-modal', 'open');
      }, 1000);
    }

    $(".close-activity-modal-button").on("click", function() {
      triggerModal("#activity-modal", 'close');
    });

    if (state == 3 && $("#client-admin-demo-analytics").length > 0) {
      activityPageIntro();
    }

    $("#share_airbo").on("click", function(e) {
      e.preventDefault();
      triggerModal("#share-modal", 'open');
    });

    if ($("#welcome-back-modal").length > 0) {
      triggerModal("#welcome-back-modal", 'open');
    }

    if (state == 4) {
      triggerModal("#onboarding-complete-modal", 'open');
    }

    $(".tile_multiple_choice_answer").on("click", function() {
      if ($("#tiles_done_message").length > 0) {
        $("#tiles_done_message").hide();
        triggerModal("#onboarding-tiles-complete-modal", 'open');
      }
    });

    $(".close-modal").on("click", function() {
      closeModal($(this).parents(".reveal-modal"));
    });
  }

  function activityPageIntro(){
    var options = {
      steps: [
        {
         intro: "Welcome to your Airbo Activity Page. Let's take a quick tour:",
         tooltipClass: "airbo airbo-onboarding",
         highlightClass: "airbo"
        },
        {
          element: ".title_block",
          intro: "This area shows total Tiles you've posted, employees activated and what percentage of your population is using Airbo.",
          tooltipClass: "airbo airbo-onboarding",
          highlightClass: "airbo"

        },

        {
          element: ".activity-graph",
          intro: "Use the chart to analyze  Tile specific activity by date range.",
          position: "top",
          tooltipClass: "airbo airbo-onboarding",
          highlightClass: "airbo"
        },

        {
          element: "#board_stats_grid",
          intro: "This real-time activity feed shows what employees are doing right now on Airbo.",
          tooltipClass: "airbo airbo-onboarding",
          highlightClass: "airbo"
        }
      ],
      showStepNumbers: false,
      tooltipPosition: "auto",
      tooltipClass: "onboarding-activity",
      doneLabel: "Got it",
      overlayOpacity: 1,
      scrollToElement: true,
      exitOnEsc: false,
      exitOnOverlayClick: false,
    };


    intro = introJs();
    intro.setOptions(options);
    intro.start();

    intro.oncomplete(function() {
      triggerModal("#onboarding-complete-modal", 'open');
      Airbo.UserOnboardingUpdate.thirdUpdate($(".onboarding-body").data("id"));
    });
  }


  function triggerModal(modalSelector, action) {
    $(modalSelector).foundation('reveal', action, {
      animation: 'fadeAndPop',
      animation_speed: 350
    });
  }

  function closeModal(modal) {
    triggerModal(modal, "close");
  }

  return {
    init: init
  };
}());
