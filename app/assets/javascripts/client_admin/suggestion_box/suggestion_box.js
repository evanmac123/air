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

//acceptBtnSel = function() {
  //return ".accept_button a";
//};

//acceptBtn = function() {
  //return $(acceptBtnSel());
//};

//acceptModalSel = function() {
  //return "#accept-tile-modal";
//};

//acceptModal = function() {
  //return $(acceptModalSel());
//};

//confirmInAcceptModal = function() {
  //return $(acceptModalSel() + " .confirm");
//};

//undoInAcceptModal = function() {
  //return $(acceptModalSel() + " .undo");
//};

//ignoreBtnSel = function() {
  //return ".ignore_button a";
//};

//ignoreBtn = function() {
  //return $(ignoreBtnSel());
//};

//undoIgnoreBtnSel = function() {
  //return ".undo_ignore_button a";
//};

//undoIgnoreBtn = function() {
  //return $(undoIgnoreBtnSel());
//};

//submittedTile = function() {
  //return $(".tile_thumbnail.user_submitted").closest(".tile_container");
//};

showSection = function(section) {
  if (section === 'draft') {
    $("#draft_tiles").addClass('draft_selected').removeClass('suggestion_box_selected');
  } else {
    $("#draft_tiles").removeClass('draft_selected').addClass('suggestion_box_selected');
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
  return $.post("/ping", {
    event: 'Suggestion Box',
    properties: {
      client_admin_action: action
    }
  });
};

//window.acceptModalForTileFromPreviewPage = function(url) {
  //window.accessActionParams = {
    //url: url,
    //undo: false,
    //ajax: false
  //};
  //return acceptModal().foundation('reveal', 'open');
//};

window.suggestionBox = function() {
  var acceptTile, acceptTileFromPreviewPage, acceptingTileVisibility, ignoreTile, insertIgnoredTile, insertUserSubmittedTile, prepareAccessModal, undoIgnoreTile, updateUserSubmittedTilesCounter;
  draftTitle().click(function() {
    return showSection('draft');
  });

  boxTitle().click(function() {
    removeNewTileTip();
    showSection('box');
    return ping("Suggestion Box Opened");
  });

  //acceptingTileVisibility = function(action) {
    //var tile;
    //tile = window.accessActionParams["tile"];
    //return tileVisibility(tile, action);
  //};

  //prepareAccessModal = function(acceptBtn) {
    //var tile;
    //tile = acceptBtn.closest(".tile_container");
    //window.accessActionParams = {
      //url: acceptBtn.attr("href"),
      //tile: tile,
      //undo: false,
      //ajax: true
    //};
    //return acceptingTileVisibility("hide");
  //};

  //updateUserSubmittedTilesCounter = function() {
    //return $("#user_submitted_tiles_counter").html(submittedTile().length);
  //};

  //acceptTileFromPreviewPage = function() {
    //if (window.accessActionParams["undo"]) {
      //$.ajax({
        //type: 'PUT',
        //dataType: "json",
        //url: window.accessActionParams["url"],
        //success: function(data) {
          //return window.location.href = "/client_admin/tiles/" + data.tile_id;
        //}
      //});
    //}
    //return window.accessActionParams = {};
  //};

  //acceptTile = function() {
    //if (window.accessActionParams["undo"]) {
      //return acceptingTileVisibility("show");
    //} else {
      //return $.ajax({
        //type: 'PUT',
        //dataType: "json",
        //url: window.accessActionParams["url"],
        //success: function(data) {
          //if (data.success) {
            //acceptingTileVisibility("remove");
            //$("#draft .no_tiles_section").after(data.tile);
            //window.updateTilesAndPlaceholdersAppearance();
            //return updateUserSubmittedTilesCounter();
          //} else {
            //return acceptingTileVisibility("show");
          //}
        //}
      //});
    //}
  //};

  //$(document).on('click', acceptBtnSel(), function(e) {
    //e.preventDefault();
    //prepareAccessModal($(this));
    //return acceptModal().foundation('reveal', 'open');
  //});

  //confirmInAcceptModal().click(function(e) {
    //e.preventDefault();
    //return acceptModal().foundation('reveal', 'close');
  //});

  //undoInAcceptModal().click(function(e) {
    //e.preventDefault();
    //window.accessActionParams["undo"] = true;
    //return acceptModal().foundation('reveal', 'close');
  //});

  //$(document).on('closed.fndtn.reveal', acceptModalSel(), function() {
    //if (window.accessActionParams["ajax"]) {
      //return acceptTile();
    //} else {
      //return acceptTileFromPreviewPage();
    //}
  //});

  //insertIgnoredTile = function(tile) {
    //if (submittedTile().length > 0) {
      //submittedTile().last().after(tile);
    //} else {
      //suggestionBox().append(tile);
    //}
    //return window.updateTilesAndPlaceholdersAppearance();
  //};

  //ignoreTile = function(ignoreButton) {
    //var tile, url;
    //tile = ignoreButton.closest(".tile_container");
    //url = ignoreButton.attr("href");
    //tileVisibility(tile, "hide");
    //return $.ajax({
      //type: 'PUT',
      //dataType: "json",
      //url: url,
      //success: function(data) {
        //if (data.success) {
          //tileVisibility(tile, "remove");
          //insertIgnoredTile(data.tile);
          //return updateUserSubmittedTilesCounter();
        //} else {
          //return tileVisibility(tile, "show");
        //}
      //}
    //});
  //};

  //$(document).on('click', ignoreBtnSel(), function(e) {
    //e.preventDefault();
    //return ignoreTile($(this));
  //});

  //insertUserSubmittedTile = function(tile) {
    //if (submittedTile().length > 0) {
      //submittedTile().first().before(tile);
    //} else {
      //suggestionBox().append(tile);
    //}
    //return window.updateTilesAndPlaceholdersAppearance();
  //};

  //undoIgnoreTile = function(button) {
    //var tile, url;
    //tile = button.closest(".tile_container");
    //url = button.attr("href");
    //tileVisibility(tile, "hide");
    //return $.ajax({
      //type: 'PUT',
      //dataType: "json",
      //url: url,
      //success: function(data) {
        //if (data.success) {
          //tileVisibility(tile, "remove");
          //insertUserSubmittedTile(data.tile);
          //return updateUserSubmittedTilesCounter();
        //} else {
          //return tileVisibility(tile, "show");
        //}
      //}
    //});
  //};

  //return $(document).on('click', undoIgnoreBtnSel(), function(e) {
    //e.preventDefault();
    //return undoIgnoreTile($(this));
  //});
};
