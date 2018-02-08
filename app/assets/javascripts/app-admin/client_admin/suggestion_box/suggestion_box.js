var Airbo = window.Airbo || {};

Airbo.SuggestionBox = (function() {
  var boxTitleSel = "#suggestion_box_title",
    draftTitleSel = "#draft_title",
    suggestionBoxSel = "#suggestion_box",
    boxTitle,
    draftTitle,
    suggestionBox;

  function showSection(section) {
    if (section === "draft") {
      $("#draft_tiles")
        .addClass("draft_selected")
        .removeClass("suggestion_box_selected");
      $("#suggestion_box_sub_menu").hide();
    } else {
      $("#draft_tiles")
        .removeClass("draft_selected")
        .addClass("suggestion_box_selected");
      $("#suggestion_box_sub_menu").show();
    }

    Airbo.DraftSectionExpander.compressSection();
  }

  function tileVisibility(tile, action) {
    if (action === "show") {
      tile.removeClass("hidden_tile").show();
    } else if (action === "hide") {
      tile.addClass("hidden_tile").hide();
    } else if (action === "remove") {
      tile.remove();
    }

    window.updateTilesAndPlaceholdersAppearance();
  }

  function removeNewTileTip() {
    return $(".joyride-tip-guide.tile").remove();
  }

  function ping(action) {
    Airbo.Utils.ping("Suggestion Box", { client_admin_action: action });
  }

  function initTiles() {
    draftTitle.click(function(e) {
      e.preventDefault();
      return showSection("draft");
    });

    boxTitle.click(function(e) {
      e.preventDefault();
      removeNewTileTip();
      showSection("box");
      return ping("Suggestion Box Opened");
    });
  }

  function initTabs() {
    $(".draft-tabs>li>a").on("click", function() {
      $(this)
        .parents(".draft-tabs")
        .find("a")
        .removeClass("selected");
      $(this).addClass("selected");
    });
  }

  function init() {
    boxTitle = $(boxTitleSel);
    draftTitle = $(draftTitleSel);
    suggestionBox = $(suggestionBoxSel);
    initTiles();
    initTabs();

    $(".draft-toggler a.unfinished").click(function() {
      $(".tile_container.unfinished").hide();
      Airbo.TileDragDropSort.updateTilesAndPlaceholdersAppearance();
    });

    Airbo.SuggestionBoxAccessManager.init();
    Airbo.SuggestionBoxHelpModal.init();
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".draft-and-suggested-tiles").length > 0) {
    // Airbo.SuggestionBox.init();
  }
});
