var Airbo = window.Airbo || {};

Airbo.SuggestionBoxHelpModal = (function() {
  function init() {
    $("#suggestion_box_sub_menu .help").click(function(e) {
      e.preventDefault();
      $("#suggestion_box_help_modal").foundation("reveal", "open");
    });

    $("#suggestion_box_help_modal")
      .find(".close, .close-reveal-modal")
      .click(function(e) {
        e.preventDefault();
        $("#suggestion_box_help_modal").foundation("reveal", "close");
      });

    $("#suggestion_box_help_modal")
      .find(".submit")
      .click(function(e) {
        e.preventDefault();
        $("#suggestions_access_modal").foundation("reveal", "open");
      });
  }

  return {
    init: init
  };
})();
