var Airbo = window.Airbo || {};

$(function() {
  if (Airbo.Utils.nodePresent(".js-mobile-board-switcher")) {
    $(".board_switch_dropdown select").on("change", function(event) {
      var selectedOption = $(event.target).find("option:selected");
      var boardId = selectedOption.val();
      $("#board-switch-link-" + boardId).click();
    });
  }
});
