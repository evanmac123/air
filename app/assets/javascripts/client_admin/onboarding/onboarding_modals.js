var Airbo = window.Airbo || {};

Airbo.OnboardingModals = (function(){

  function init() {
    var state = $(".onboarding-body").data("state");

    $(".open-progress-modal").on("click", function() {
      $('#progress-modal').foundation('reveal', 'open', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    $(".close-progress-modal").on("click", function() {
      $('#progress-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    $(".schedule-demo-button").on("click", function() {
      $.post("/api/v1/email_info_requests", $("#demo-request-form").serialize());
      $('#schedule-demo-modal').foundation('reveal', 'open', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    $(".close-demo-button").on("click", function() {
      $('#schedule-demo-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    $(".close-board-view-button").on("click", function() {
      $('#board-view-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    if (state == 2 && $("#tile_wall").length > 0) {
      sleep(1000).then(() => {
        $('#board-view-modal').foundation('reveal', 'open', {
          animation: 'fadeAndPop',
          animation_speed: 350});
      });
    }

    $(".close-tile-view-button").on("click", function() {
      $('#tile-view-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    if (state == 2 && $("#tile_progress_bar").length > 0) {
      sleep(1000).then(() => {
        $('#tile-view-modal').foundation('reveal', 'open', {
          animation: 'fadeAndPop',
          animation_speed: 350});
      });
    }

    $(".close-activity-modal-button").on("click", function() {
      $('#activity-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });


    $(".close-viewed-activity-modal-button").on("click", function() {
      $('#activity-modal').foundation('reveal', 'close', {
  animation: 'fadeAndPop',
  animation_speed: 350});
    });

    if (state == 3 && $("#client-admin-demo-analytics").length > 0) {
      sleep(1000).then(() => {
        $('#viewed-activity-modal').foundation('reveal', 'open', {
          animation: 'fadeAndPop',
          animation_speed: 350});
      });
    }

    if ($("#share-modal").length > 0) {
      $('#share-modal').foundation('reveal', 'open', {
        animation: 'fadeAndPop',
        animation_speed: 350});
    }

    if ($("#onboarding-complete-modal").length > 0) {
      $('#onboarding-complete-modal').foundation('reveal', 'open', {
        animation: 'fadeAndPop',
        animation_speed: 350});
    }
  }

  function showActivityModal() {
    var currentTile = $(".tile_holder").data("current-tile-id").toString();
    var currentTileIds = $(".tile_holder").data("current-tile-ids").split(",");

    return currentTileIds.indexOf(currentTile) % 2 == 1;
  }

  function sleep (time) {
    return new Promise((resolve) => setTimeout(resolve, time));
  }

  return {
    init: init
  };
}());
