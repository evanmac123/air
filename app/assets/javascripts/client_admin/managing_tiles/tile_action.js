var Airbo = window.Airbo || {};

Airbo.TileAction = (function(){
  var tileWrapperSelector =".tile_container"
    , tileModalSelector = "#tile_form_modal"
  ;
  function closeModal(modal){
   modal.foundation("reveal", "close");
  }
  function tileByStatusChangeTriggerLocation(target){
    var criteria = "[data-tile-id=" + target.data("tileid") + "]";//"[data-status='draft']"

    if(target.parents(tileWrapperSelector).length !== 0){
      //Trigger directly by action button on the tile outside of the modal
      return target.parents(tileWrapperSelector);
    }else if(modalTrigger && modalTrigger.parents(tileWrapperSelector).length !=0){
      //Triggered inside modal of a prexisting tile
      return modalTrigger.parents(tileWrapperSelector);
    }else{
      //newly created tile so no trigger was present prior to the tile being created. Assume it is currently in dreaft
      return $(tileWrapperSelector).filter(criteria);
    }

  }
  function replaceTileContent(tile, id){
    selector = tileWrapperSelector + "[data-tile-id=" + id + "]";
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
     replaceTileContent(newTile, newTile.data("tileId"));
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
          Airbo.TileThumbnail.initTile( $(data).data("tileId") );
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
  return {
    updateStatus: updateStatus
  }
}());
