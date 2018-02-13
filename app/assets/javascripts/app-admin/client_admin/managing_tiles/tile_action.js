var Airbo = window.Airbo || {};

Airbo.TileAction = (function() {
  var tileWrapperSelector = ".tile_container",
    tileModalSelector = "#tile_preview_modal";

  //
  // => Update Status
  //
  function movePing(updatedTile, status, action) {
    var mess = {
      active: "Posted",
      draft: "Drafted",
      archive: "Archived",
      user_submitted: "Unignored",
      ignored: "Ignored"
    };

    var config = updatedTile.data("config");
    var data = updatedTile.data();

    Airbo.Utils.ping("Tile " + mess[status], {
      action: action,
      tile_id: data["tile-container-id"],
      media_source: data.mediaSource,
      tile_module: config.type,
      tile_type: config.signature,
      allow_free_reponse: config.allowFreeResponse,
      is_anonymous: config.isAnonymous,
      has_attachments: data.hasAttachments,
      attachment_count: data.attachmentCount
    });
  }

  function updateStatus(link) {
    var currTile = tileByStatusChangeTriggerLocation(link);
    var data = {
      sort: {
        new_status: link.data("status")
      }
    };

    function isRepostingArchivedTile() {
      return link.data("action") === "unarchive";
    }

    function closeAnyToolTips() {
      if (link.parents(".tooltipster-base").length > 0) {
        $("li#stat_toggle").tooltipster("hide");
      }
    }

    function submit() {
      $.ajax({
        url: link.data("url") || link.attr("href"),
        type: "POST",
        data: data,
        success: function(data, status, xhr) {
          updatedTile = $(data.tileHTML);
          closeAnyToolTips();
          movePing(
            updatedTile,
            updatedTile.data("status"),
            "Clicked button to move"
          );

          Airbo.PubSub.publish("/tile-admin/tile-status-updated", {
            currTile: currTile,
            updatedTile: updatedTile
          });

          Airbo.PubSub.publish("updateTileCounts", data.meta);
        }
      });
    }

    if ($(".explore-search-results-client_admin").length > 0) {
      data.from_search = true;
    }

    if (isRepostingArchivedTile()) {
      confirmUnarchive(function(isConfirm) {
        if (isConfirm) {
          if (Airbo.Utils.userIsSiteAdmin()) {
            data.sort.redigest = $(".sweet-alert input#digestable").is(
              ":checked"
            );
          }
          submit();
        }
      });
    } else {
      submit();
    }
  }

  //
  // => Duplication
  //
  //

  function swapModalButtons() {
    $("button.cancel").before($("button.confirm"));
  }

  function makeDuplication(trigger) {
    swal({
      title: "Tile Copying to Drafts",
      text:
        "<div class='spinner'><i class='blue fa fa-spinner fa-spin fa-3x'></i></div>",
      customClass: "airbo",
      animation: false,
      showConfirmButton: false,
      html: true
    });

    $.ajax({
      type: "POST",
      dataType: "json",
      url: trigger.attr("href"),
      success: function(data, status, xhr) {
        swal.close();
        Airbo.PubSub.publish("/tile-admin/tile-copied", { data: data });
        Airbo.PubSub.publish("incrementTileCounts", { status: "draft" });
      },

      error: function(jqXHR, textStatus, error) {
        console.log(error);
      }
    });
  }
  //
  // => Deletion
  //

  function confirmDeletion(target) {
    function deleteTile(target) {
      var tile = tileByStatusChangeTriggerLocation(target);

      $.ajax({
        url: target.data("url") || target.attr("href"),
        type: "delete",
        success: function(data, status, xhr) {
          swal.close();
          closeModal($(tileModalSelector));
          Airbo.PubSub.publish("/tile-admin/tile-deleted", { tile: tile });
          Airbo.PubSub.publish("updateTileCounts", data.meta);
        }
      });
    }
    swal(
      {
        title: "",
        text:
          "Deleting a tile cannot be undone.\n\nAre you sure you want to delete this tile?",
        customClass: "airbo",
        animation: false,
        closeOnConfirm: false,
        showCancelButton: true,
        showLoaderOnConfirm: true
      },

      function(isConfirm) {
        if (isConfirm) {
          deleteTile(target);
        }
      }
    );

    swapModalButtons();
  }

  function closeModal(modal) {
    modal.foundation("reveal", "close");
  }

  function tileByStatusChangeTriggerLocation(target) {
    var tileContainerSelect =
      ".tile_container[data-tile-container-id=" + target.data("tile-id") + "]";
    return $(tileContainerSelect);
  }

  function confirmUnarchive(confirmCallback) {
    var unarchivePrompt =
      "Users who completed it before won't see it again. If you want to re-use the content, please create a new Tile.";
    var adminUnarchivePrompt =
      "<p class='extra-interaction'><label>Click to include in the digest when reposted: <input type='checkbox' value='yes' id='digestable'/> </label></p>";
    var txt = Airbo.Utils.userIsSiteAdmin()
      ? adminUnarchivePrompt
      : unarchivePrompt;
    swal(
      {
        title: "Are you sure you want to repost this Tile?",
        text: txt,
        customClass: "airbo",
        showConfirmationButton: true,
        showCancelButton: true,
        cancelButtonText: "Cancel",
        confirmButtonText: "Confirm",
        closeOnConfirm: true,
        closeOnCancel: true,
        allowEscapeKey: true,
        html: true,
        animation: false
      },
      confirmCallback
    );
  }

  return {
    movePing: movePing,
    updateStatus: updateStatus,
    makeDuplication: makeDuplication,
    confirmDeletion: confirmDeletion,
    confirmUnarchive: confirmUnarchive,
    tileByStatusChangeTriggerLocation: tileByStatusChangeTriggerLocation
  };
})();
