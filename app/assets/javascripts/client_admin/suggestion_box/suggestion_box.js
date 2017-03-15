var acceptBtn, acceptBtnSel, acceptModal, acceptModalSel, boxTitle, confirmInAcceptModal, draftTitle, ignoreBtn, ignoreBtnSel, ping, removeNewTileTip, showSection, submittedTile, suggestionBox, tileVisibility, undoIgnoreBtn, undoIgnoreBtnSel, undoInAcceptModal;

draftTitle = function() {
  return $("#draft_title");
};

suggestionBox = function() {
  return $("#suggestion_box");
};

boxTitle = function() {
  return $("#suggestion_box_title");
};


showSection = function(section) {
  if (section === 'draft') {
    $("#draft_tiles").addClass('draft_selected').removeClass('suggestion_box_selected');
    $("#suggestion_box_sub_menu").hide();
  } else {
    $("#draft_tiles").removeClass('draft_selected').addClass('suggestion_box_selected');
    $("#suggestion_box_sub_menu").show();
  }
  updateShowMoreDraftTilesButton();
  return window.compressSection();
};

tileVisibility = function(tile, action) {
  if (action === "show") {
    tile.removeClass("hidden_tile").show();
  } else if (action === "hide") {
    tile.addClass("hidden_tile").hide();
  } else if (action === "remove") {
    tile.remove();
  }
  return window.updateTilesAndPlaceholdersAppearance();
};

removeNewTileTip = function() {
  return $(".joyride-tip-guide.tile").remove();
};

ping = function(action) {
  Airbo.Utils.ping('Suggestion Box', { client_admin_action: action } );
};

window.suggestionBox = function() {
  var acceptTile, acceptTileFromPreviewPage, acceptingTileVisibility, ignoreTile, insertIgnoredTile, insertUserSubmittedTile, prepareAccessModal, undoIgnoreTile, updateUserSubmittedTilesCounter;
  draftTitle().click(function(e) {
    e.preventDefault();
    return showSection('draft');
  });

  boxTitle().click(function(e) {
    e.preventDefault();
    removeNewTileTip();
    showSection('box');
    return ping("Suggestion Box Opened");
  });

};

$(function(){
  $(".tabs>li>a").on("click", function(){
    $(this).parents(".tabs").find("a").removeClass("selected");
    $(this).addClass("selected");
  });
});
