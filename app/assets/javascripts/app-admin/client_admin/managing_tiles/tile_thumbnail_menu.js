var Airbo = window.Airbo || {};

Airbo.TileThumbnailMenu = (function() {
  var tileCreator, instances;

  function closeToolTips() {
    instances = $.tooltipster.instances();
    $.each(instances, function(i, instance) {
      instance.close();
    });
  }

  function initTileActions() {
    $("body").on(
      "click",
      ".tile_thumbnail_menu .delete_tile, .tile_buttons .delete_tile",
      function(event) {
        event.preventDefault();
        closeToolTips();
        Airbo.TileAction.confirmDeletion($(this));
      }
    );

    $("body").on("click", ".tile_thumbnail_menu .duplicate_tile", function(
      event
    ) {
      event.preventDefault();
      closeToolTips();
      Airbo.TileAction.makeDuplication($(this));
    });

    $("body").on("click", ".tile_thumbnail_menu .post_tile", function(event) {
      event.preventDefault();
      closeToolTips();
      Airbo.TileAction.updateStatus($(this));
    });
  }

  function setMenuActiveState(origin, active) {
    if (active) {
      origin.addClass("active");
      origin.closest(".tile-wrapper").addClass("active_menu");
    } else {
      origin.removeClass("active");
      origin.closest(".tile-wrapper").removeClass("active_menu");
    }
  }

  function initToolTipMenu() {
    initMoreBtn();
  }

  function initMoreBtn() {
    var selector = "body .pill.more:not(.tooltipstered)";
    //TODO remove duplicaiton
    $(selector).tooltipster({
      theme: "tooltipster-shadow tooltipster-thumbnail-menu",
      interactive: true,
      position: "bottom",
      side: "top",
      trigger: "click",
      autoClose: true,

      functionInit: function(instance, helper) {
        var content = $(helper.origin)
          .find(".tooltip-content")
          .detach();

        content.show();
        instance.content(content);
      },

      functionBefore: function(instance, helper) {
        instance.content().css({ visibility: "visible" });
        setMenuActiveState($(helper.origin), true);
      },

      functionAfter: function(instance, helper) {
        setMenuActiveState($(helper.origin), false);
      },

      functionReady: function(instance, helper) {}
    });
  }

  function init() {
    initToolTipMenu();
    initTileActions();
    return this;
  }
  return {
    init: init,
    initMoreBtn: initMoreBtn
  };
})();
