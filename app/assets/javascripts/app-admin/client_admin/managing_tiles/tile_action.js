var Airbo = window.Airbo || {};

Airbo.TileAction = (function() {
  var tileWrapperSelector = ".tile_container";
  var tileModalSelector = "#tile_preview_modal";

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

    function manuallyPostingTile() {
      return link.data("action") === "active";
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
          submit();
        }
      });
    } else if (manuallyPostingTile()) {
      confirmPost(function(isConfirm) {
        if (isConfirm) {
          submit();
        }
      });
    } else {
      submit();
    }
  }

  function swapModalButtons() {
    $("button.cancel").before($("button.confirm"));
  }

  function makeDuplication(trigger) {
    var loadingSpinner = document.createElement("div");
    loadingSpinner.className = "spinner";
    loadingSpinner.innerHTML =
      "<i class='blue fa fa-spinner fa-spin fa-3x'></i>";
    swal({
      title: "Tile Copying to Drafts",
      content: loadingSpinner,
      className: "airbo",
      buttons: false
    });

    $.ajax({
      type: "POST",
      dataType: "json",
      url: trigger.attr("href"),
      success: function(data, status, xhr) {
        swal.close();
        Airbo.PubSub.publish("/tile-admin/tile-copied", { data: data });
      },

      error: function(jqXHR, textStatus, error) {
        console.log(error);
      }
    });
  }

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

    swal({
      title: "",
      text:
        "Deleting a tile cannot be undone.\n\nAre you sure you want to delete this tile?",
      className: "airbo",
      buttons: true
    }).then(function(isConfirm) {
      if (isConfirm) {
        deleteTile(target);
      }
    });

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

  function confirmPost(confirmCallback) {
    var prompt =
      "Tiles are posted automatically when they are delivered. If you manually post a Tile, it will not appear in your next Tile Digest.";
    var confirmText = "Post";

    swapTemplate(prompt, confirmText, confirmCallback);
  }

  function confirmUnarchive(confirmCallback) {
    var prompt =
      "Users who have completed this Tile already will not see it again. If you want to re-use the content, it may be better to create a copy.";
    var confirmText = "Post Again";

    swapTemplate(prompt, confirmText, confirmCallback);
  }

  function swapTemplate(prompt, confirmText, callback) {
    swal({
      title: "Are you sure about that?",
      text: prompt,
      className: "airbo",
      buttons: ["Cancel", confirmText],
      closeOnEsc: true
    }).then(callback);
  }

  return {
    updateStatus: updateStatus,
    makeDuplication: makeDuplication,
    confirmDeletion: confirmDeletion
  };
})();
