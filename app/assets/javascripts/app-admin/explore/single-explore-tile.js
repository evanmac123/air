var Airbo = window.Airbo || {};

Airbo.ExploreSingleTile = (function() {
  var entryPoint;
  var tileType;

  function initAnswerCorrectModal() {
    $(".js-multiple-choice-answer.correct, .clicked_right_answer").on(
      "click",
      function(e) {
        e.preventDefault();
        if ($(this).hasClass("free-text")) {
          if (!$(".js-free-form-response").val()) {
            return;
          }
        }

        if (tileType === "public") {
          publicTileCompleted();
        } else {
          exploreTileCompleted();
        }
      }
    );
  }

  function publicTileCompleted() {
    Airbo.Utils.ping("Single Explore Tile", { action: "Completed Tile" });
    initAnswerCorrectModal();
    launchModal();
  }

  function exploreTileCompleted() {
    Airbo.Utils.ping("Single Explore Tile", { action: "Completed Tile" });
    initAnswerCorrectModal();
    launchModal();
  }

  function launchModal() {
    swal({
      title: "Tile Completed!",
      type: "success",
      buttons: ["Close"],
      className: "airbo",
      allowOutsideClick: true
    });
  }

  function init() {
    $entryPoint = $(".js-single-tile-base");
    tileType = $entryPoint.data("exploreOrPublic");

    Airbo.UserTileShareOptions.init();
    initAnswerCorrectModal();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".single-tile-base")) {
    Airbo.ExploreSingleTile.init();
  }
});
