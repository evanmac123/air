var Airbo = window.Airbo || {};

Airbo.SearchTileActions = (function(){
  var tileWrapperSelector = ".tile_container",
      tileModalSelector   = "#tile_preview_modal",
      editSelector        = ".edit_button a";

  //
  // => Update Status
  //
  function updateStatus(target) {
    tile = Airbo.TileAction.tileByStatusChangeTriggerLocation(target);
    function closeAnyToolTips() {
      if ((target).parents(".tooltipster-base").length > 0) {
        $("li#stat_toggle").tooltipster("hide");
      }
    }

    if (tile.hasClass("unfinished")){
      Airbo.Utils.alert(Airbo.Utils.Messages.incompleteTile);
    } else {
      submitTileForUpadte(tile,target, closeAnyToolTips);
    }
  }

  function submitTileForUpadte(tile, target, postProcess ){
    var currentStatus = tile.data().status;
    var newStatus = target.data("status");
    var data = { "update_status": { "status": newStatus, "allowRedigest": false } };

    function isRepostingArchivedTile(){
     return currentStatus === "archive";
    }

    function submit(){
      $.ajax({
        url: target.data("url") || target.attr("href"),
        type: "put",
        data: $.extend(data, { from_search: true }),
        dataType: "html",
        success: function(data, status,xhr){
          $(tileModalSelector).foundation("reveal", "close");
          tile.replaceWith(data);
          Airbo.SearchTileThumbnail.init( $(data).data("tile-container-id"));
          Airbo.TileAction.movePing($(data), $(data).data("status"), "Clicked button to move");
        }
      });
    }

    if (isRepostingArchivedTile()) {
      Airbo.TileAction.confirmUnarchive(function(isConfirm){
        if (isConfirm) {
          if(Airbo.Utils.userIsSiteAdmin()){
            data.update_status.redigest = $(".sweet-alert input#digestable").is(':checked');
          }
          submit();
        }
      });
    } else{
      submit();
    }
  }

  //
  // => Duplication
  //
  function swapModalButtons(){
    $("button.cancel").before($("button.confirm"));
  }

  function processingDuplicationModal() {
    swal(
      {
        title: "Tile Copying to Drafts",
        text: "<div class='spinner'><i class='fa fa-spinner fa-3x' aria-hidden='true'></i></div>",
        customClass: "airbo",
        animation: false,
        showConfirmButton: false,
        html: true
      }
    );
    swapModalButtons();
  }

  function afterDuplicationModal(tileIdn, renderedCopyToCurPage){
    swal(
      {
        title: "Tile Copied to Drafts",
        customClass: "airbo",
        animation: false,
        showCancelButton: renderedCopyToCurPage,
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

  function makeDuplication(trigger, renderCopyToCurPage) {
    processingDuplicationModal();

    $.ajax({
      type: "POST",
      dataType: "json",
      url: trigger.attr("href") ,
      success: function(data, status,xhr){
        if (renderCopyToCurPage) {
          // Implement when we fully refactor
          // Airbo.TileManager.updateTileSection(data);
          // updateShowMoreDraftTilesButton();
        }
        afterDuplicationModal(data.tileId, renderCopyToCurPage);
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
        $(tileModalSelector).foundation("reveal", "close");
        postProcess();
      }
    });
  }

  function confirmDeletion(trigger, tile, renderPlaceHolder){
    function postProcess() {
      var isArchiveSection = tile.data("status") == "archive";
      tile.remove();

      if (renderPlaceHolder) {
        // Impelment in when we fully refactor
      }
    }

    swal(
      {
        title: "",
        text: "Deleting a tile cannot be undone.\n\nAre you sure you want to delete this tile?",
        customClass: "airbo",
        animation: false,
        closeOnConfirm: false,
        showCancelButton: true,
        showLoaderOnConfirm: true
      },

      function(isConfirm){
        if (isConfirm) {
          submitTileForDeletion(tile, trigger, postProcess);
        }
      }
    );

    swapModalButtons();
  }

  return {
    makeDuplication: makeDuplication,
    confirmDeletion: confirmDeletion,
    updateStatus: updateStatus,
  };
}());
