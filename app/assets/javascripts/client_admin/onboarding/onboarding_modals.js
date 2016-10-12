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
      setTimeout(function() {
        triggerModal('#board-view-modal', 'open');
      }, 1000);
    }

    $(".close-tile-view-button").on("click", function() {
      triggerModal("#tile-view-modal", 'close');
    });

    if (state == 2 && $(".tile_main").length > 0) {
      setTimeout(function() {
        triggerModal('#tile-view-modal', 'open');
      }, 1000);
    }

    $(".close-activity-modal-button").on("click", function() {
      triggerModal("#activity-modal", 'close');
    });


    $(".close-viewed-activity-modal-button").on("click", function() {
      triggerModal("#activity-modal", 'close');
    });

    if (state == 3 && $("#client-admin-demo-analytics").length > 0) {
      setTimeout(function() {
        triggerModal('#viewed-activity-modal', 'open');
      }, 1000);
    }

    if ($("#share-modal").length > 0) {
      triggerModal("#share-modal", 'open');
    }

    if ($("#welcome-back-modal").length > 0) {
      triggerModal("#welcome-back-modal", 'open');
    }

    if ($("#onboarding-complete-modal").length > 0) {
      triggerModal("#onboarding-complete-modal", 'open');
    }
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
