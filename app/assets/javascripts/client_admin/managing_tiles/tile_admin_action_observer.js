var Airbo = window.Airbo || {};

Airbo.TileAdminActionObserver = (function(){
  var tileModalSelector = "#tile_preview_modal"

  function init(){
    Airbo.PubSub.subscribe("/tile-admin/tile-status-updated", function(event, payload){
      tileUpdateStatusSucces(payload)
    });


    Airbo.PubSub.subscribe("/tile-admin/tile-copied", function(event, payload){
        Airbo.TileManager.updateTileSection(payload.data);
        afterDuplicationModal(payload.data.tileId);
        updateShowMoreDraftTilesButton();
    });

    Airbo.PubSub.subscribe("/tile-admin/tile-deleted", function(event, payload){
      var isArchiveSection = payload.tile.data("status") == "archive";
      payload.tile.remove();
      Airbo.Utils.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
      updateShowMoreDraftTilesButton();
      if(isArchiveSection) {
        loadLastArchiveTile();
      }
    });
  }


  
  function updateUserSubmittedTilesCounter() {
    submittedTile = $(".tile_thumbnail.user_submitted");
    $("#suggestion_box_title").find(".num-items").html("(" + submittedTile.length + ")");
  }

  function afterDuplicationModal(tileId){
    swal(
      {
        title: "Tile Copied to Drafts",
        customClass: "airbo",
        animation: false,
        showCancelButton: true,
        cancelButtonText: "Edit Tile"
      },

      function(isConfirm){
        var tile;
        if (!isConfirm) {
          tile = Airbo.TileManager.tileContainerByDataTileId(tileId);
          tile.find(".edit_button a").trigger("click");
        }
      }
    );
    swapModalButtons();
  }

  function swapModalButtons(){
    $("button.cancel").before($("button.confirm"));
  }

  function tileUpdateStatusSucces(payload){
      var currTile = payload.currTile
      var updatedTile = payload.updatedTile;

      Airbo.Utils.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
      swal.close();
      if (window.location.pathname.indexOf("inactive_tiles") > 0) {
        currTile.hide();
      } else {

        $(tileModalSelector).foundation("reveal", "close");
        moveTile(currTile, updatedTile);
      }
  }


  function loadLastArchiveTile() {
    var archiveSection = $(".manage_section#archive");
    var placeholders = tilePlaceholdersInSection( archiveSection );
    if(placeholders.length === 0 ) {
      return;
    }
    var tiles = notTilePlaceholdersInSection( archiveSection );
    var lastTileId = tiles.last().data("tile-container-id");
    $.ajax({
      type: "GET",
      dataType: "json",
      url: '/client_admin/tiles/' + lastTileId + '/next_tile',
      success: function(data, status,xhr){
        if(data.tileId && lastTileId != data.tileId) {
          fillInLastTile(data.tileId, "archive", data.tile);
          // placeholders.first().replaceWith(data.tile);
        }
      },

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }

  function moveTile(currTile, updatedTile){
    function fromSuggestionBox() {
      return  currTile.data("status") == "user_submitted" || status == "ignored";
    }

    sections = {
      "active": "active",
      "draft": "draft",
      "archive": "archive",
      "user_submitted": "suggestion_box",
      "ignored": "suggestion_box"
    };

    var status = updatedTile.data("status");
    var newSection = "#" + sections[status];

   
      currTile.remove();
      $(newSection).prepend(updatedTile);
      Airbo.TileDragDropSort.updateTilesAndPlaceholdersAppearance();

    if (fromSuggestionBox(currTile)) {
      updateUserSubmittedTilesCounter();
    }

    Airbo.TileThumbnailMenu.initMoreBtn(updatedTile.find(".pill.more"));
  }

  function replaceTileContent(tile, id){
    selector = ".tile_container[data-tile-container-id=" + id + "]";
    $(selector).replaceWith(tile);
  }


  return {
    init: init
  };

})();

$(function(){
  if($(".client_admin-tiles-index").length > 0){
    Airbo.TileAdminActionObserver.init();
  }
})
