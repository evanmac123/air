var Airbo = window.Airbo || {};

Airbo.OnboardingModals = (function(){

  function init() {
    var state = $(".onboarding-body").data("state");

    $(".open-progress-modal").on("click", function() {
      triggerModal('#progress-modal', 'open');
    });

    $(".close-progress-modal").on("click", function() {
      triggerModal('#progress-modal', 'close');
    });

    $(".schedule-demo-button").on("click", function() {
      $.post("/api/v1/email_info_requests", $("#demo-request-form").serialize());
      triggerModal('#schedule-demo-modal', 'open');
    });

    $(".close-demo-button").on("click", function() {
      triggerModal('#schedule-demo-modal', 'close');
    });

    $(".close-board-view-button").on("click", function() {
      triggerModal('#board-view-modal', 'close');
    });

    if (state == 2 && $("#tile_wall").length > 0) {
      sleep(1000).then(() => {
        triggerModal('#board-view-modal', 'open');
      });
    }

    $(".close-tile-view-button").on("click", function() {
      triggerModal("#tile-view-modal", 'close');
    });

    if (state == 2 && $("#tile_progress_bar").length > 0) {
      sleep(1000).then(() => {
        triggerModal('#tile-view-modal', 'open');
      });
    }

    $(".close-activity-modal-button").on("click", function() {
      triggerModal("#activity-modal", 'close');
    });


    $(".close-viewed-activity-modal-button").on("click", function() {
      triggerModal("#activity-modal", 'close');
    });

    if (state == 3 && $("#client-admin-demo-analytics").length > 0) {
      sleep(1000).then(() => {
        triggerModal('#viewed-activity-modal', 'open');
      });
    }

    if ($("#share-modal").length > 0) {
      triggerModal("#share-modal", 'open');
    }

    if ($("#onboarding-complete-modal").length > 0) {
      triggerModal("#onboarding-complete-modal", 'open');
    }
  }

  function sleep (time) {
    return new Promise((resolve) => setTimeout(resolve, time));
  }

  function triggerModal(modalSelector, action) {
    $(modalSelector).foundation('reveal', action, {
      animation: 'fadeAndPop',
      animation_speed: 350
    });
  }

  return {
    init: init
  };
}());
