var Airbo = window.Airbo || {};

Airbo.TileAction = (function(){
  var tileWrapperSelector =".tile_container"
    , tileModalSelector = "#tile_preview_modal"
    , tileWrapperSelector =".tile_container"
  ;
  //
  // => Update Status
  //
  function closeModal(modal){
   modal.foundation("reveal", "close");
  }

   function tileContainerByDataTileId(id){
   return  $(tileWrapperSelector + "[data-tile-container-id=" + id + "]");
  }

  function tileByStatusChangeTriggerLocation(target){
      return tileContainerByDataTileId(target.data("tile-id"));
      }
  function replaceTileContent(tile, id){
    selector = tileWrapperSelector + "[data-tile-container-id=" + id + "]";
    $(selector).replaceWith(tile);
  }
  function moveTile(currTile, data){
    sections = {
       "active": "active",
       "draft": "draft",
       "archive": "archive",
       "user_submitted": "suggestion_box",
       "ignored": "suggestion_box"
    };
    var newTile = $(data)
      , status = newTile.data("status")
      , newSection = "#" + sections[status]
    ;

   if(status !=="user_submitted" && status!=="ignored"){
     currTile.remove();
     $(newSection).prepend(newTile);
     window.updateTilesAndPlaceholdersAppearance();
   }else{
     replaceTileContent(newTile, newTile.data("tile-container-id"));
     updateUserSubmittedTilesCounter();
   }
  }
  function updateUserSubmittedTilesCounter() {
    submittedTile = $(".tile_thumbnail.user_submitted");
    $("#user_submitted_tiles_counter").html(submittedTile.length);
  }
  function submitTileForUpadte(tile,target, postProcess ){
      $.ajax({
        url: target.data("url") || target.attr("href"),
        type: "put",
        data: {"update_status": target.data("status")},
        dataType: "html",
        success: function(data, status,xhr){
          closeModal( $(tileModalSelector) );
          moveTile(tile, data);
          postProcess();
          Airbo.TileThumbnail.initTile( $(data).data("tile-container-id") );
          Airbo.Utils.ping("Moved Tile in Manage", {action: "Clicked button to move", tile_id: tile.data("tile-container-id")});
        }
      });
  }
  function updateStatus(target){
    tile = tileByStatusChangeTriggerLocation(target);

    function closeAnyToolTips(){
      if((target).parents(".tooltipster-base").length > 0){
        $("li#stat_toggle").tooltipster("hide");
      }
    }

    submitTileForUpadte(tile,target, closeAnyToolTips);
  }
  //
  // => Duplication
  //
  function processingDuplicationModal() {
    swal(
      {
        title: "Tile Copying to Drafts",
        text: "<div class='spinner'><i class='fa fa-cog fa-spin fa-3x'></i></div>",
        customClass: "airbo",
        animation: false,
        showConfirmButton: false,
        html: true
        // showCancelButton: true,
        // cancelButtonText: "Edit Tile"
      }
    );
    swapModalButtons();
  }
  function swapModalButtons(){
    // $("button.cancel").before($("button.confirm"));
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
        if (!isConfirm) {
          tileContainerByDataTileId(tileId).find(editSelector).trigger("click");
        }
      }
    );
    swapModalButtons();
  }
  function makeDuplication(trigger) {
    processingDuplicationModal();

    $.ajax({
      type: "POST",
      dataType: "json",
      url: trigger.attr("href") ,
      success: function(data, status,xhr){
        Airbo.TileManager.updateTileSection(data);
        updateShowMoreDraftTilesButton();
        afterDuplicationModal(data.tileId);
      },

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }
  //
  // => Deletion
  //
  function submitTileForDeletion(tile,target, postProcess ){
      $.ajax({
        url: target.data("url") || target.attr("href"),
        type: "delete",
        success: function(data, status,xhr){
          swal.close();
          closeModal( $(tileModalSelector) );
          postProcess();
        }
      });
  }
  function confirmDeletion(trigger){
    var tile = tileByStatusChangeTriggerLocation(trigger);
    function postProcess(){
      tile.remove();
      Airbo.Utils.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
      updateShowMoreDraftTilesButton();
    }

    swal(
      {
        title: "",
        text: "Are you sure you want to delete this tile? Deleting a tile is irrevocable and you'll loose all data associated with it.",
        customClass: "airbo",
        animation: false,
        closeOnConfirm: false,
        showCancelButton: true,
        showLoaderOnConfirm: true
      },

      function(isConfirm){
        if (isConfirm) {
          submitTileForDeletion(tile, trigger,postProcess);
        }
      }
    );

    swapModalButtons();
  }
  //
  // => Acceptance
  //
  function confirmAcceptance(trigger){
    var tile = tileByStatusChangeTriggerLocation(trigger);

    function postProcess(){
      Airbo.Utils.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
      swal.close();
    }

    swal(
      {
        title: "",
        text: "Are you sure you want to accept this tile? This action cannot be undone",
        customClass: "airbo",
        animation: false,
        closeOnConfirm: false,
        showCancelButton: true,
        showLoaderOnConfirm: true
      },

      function(isConfirm){
        if (isConfirm) {
          submitTileForUpadte(tile,trigger, postProcess);
        }
      }
    );
    swapModalButtons();
  }
  return {
    updateStatus: updateStatus,
    makeDuplication: makeDuplication,
    confirmDeletion: confirmDeletion,
    confirmAcceptance: confirmAcceptance
  }
}());
