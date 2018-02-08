var Airbo = window.Airbo || {};

Airbo.TileStatsGrid = (function() {
  // Selectros
  var tileGridSectionSel = ".tile_grid_section .tile-stats-grid";
  var paginationLinkSel = tileGridSectionSel + " .pagination a";
  var sortLinkSel = tileGridSectionSel + " th a";
  var linkInGridSel = [paginationLinkSel, sortLinkSel].join(", ");
  var gridTypeSel = "#grid_type_select";

  // JQuery Objects
  var tileGridSection;
  var updateLink;
  var updatesChecker;
  var eventsInitialized;

  function ajaxResponse() {
    return function(data) {
      if (data.success) {
        tileGridSection.html(data.grid);
        initVars();
        $(document).foundation();
      }
    };
  }

  function getLinkParams(path) {
    return path.attr("href").split("?")[1] || "";
  }

  function gridRequest(url) {
    $.ajax({
      url: url,
      success: ajaxResponse(),
      dataType: "json"
    });

    updatesChecker.stopChecker();
  }

  function updateGrid(link) {
    gridRequest(updateLink + "?" + getLinkParams(link));
  }

  function initVars() {
    tileGridSection = $(tileGridSectionSel);
    updateLink = $(".tile_grid_section").data("update-link");

    if (updatesChecker) {
      updatesChecker.restart();
    } else {
      updatesChecker = Airbo.GridUpdatesChecker.init();
      updatesChecker.start();
    }
  }

  function initEvents() {
    if (eventsInitialized) {
      return;
    } else {
      eventsInitialized = true;
    }

    $(document).on("click", linkInGridSel, function(e) {
      e.preventDefault();
      updateGrid($(this));
    });

    $(document).on("change", gridTypeSel, function(e) {
      e.preventDefault();
      gridRequest(updateLink + "?grid_type=" + $(this).val());
    });
  }

  function init() {
    initVars();
    initEvents();
  }

  return {
    init: init,
    gridRequest: gridRequest
  };
})();
