var Airbo = window.Airbo || {};

Airbo.BoardActivityGrid = (function(){
  // Selectros
  var boardGridSectionSel = ".demo_grid_section",
      paginationLinkSel = boardGridSectionSel + " .pagination a",
      sortLinkSel = boardGridSectionSel + " th a",
      linkInGridSel = [paginationLinkSel, sortLinkSel].join(", "),
      gridTypeSel = "#grid_type_select";

  // JQuery Objects
  var boardGridSection;

  var updateLink,
      updatesChecker,
      eventsInitialized;

  function ajaxResponse(){
    return function (data){
      if(data.success){
        boardGridSection.replaceWith(data.grid);
        initVars();
        $(document).foundation();
      }
    };
  }

  function getLinkParams(link) {
    return link.attr("href").split('?')[1] || "";
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
    gridRequest( updateLink + "?" + getLinkParams(link) );
  }


  function initVars(){
    boardGridSection = $(boardGridSectionSel);
    updateLink = boardGridSection.data("update-link");

    if(updatesChecker){
      updatesChecker.reStart();
    } else {
      updatesChecker = Airbo.BoardGridUpdatesChecker.init();
      updatesChecker.start();
    }
  }

  function initEvents(){
    if(eventsInitialized){
      return;
    }else{
      eventsInitialized = true;
    }

    $(document).on("click", linkInGridSel, function(e){
      e.preventDefault();
      updateGrid( $(this) );
    });

    $(document).on("change", gridTypeSel, function(e){
      e.preventDefault();

      input = $(this);
      gridRequest(updateLink + "?grid_type=" + input.val());
    });
  }

  function init(){
    initVars();
    initEvents();
  }

  return {
    init: init
  };
}());

$(function(){
  if (Airbo.Utils.supportsFeatureByPresenceOfSelector("#client-admin-demo-analytics")) {
    Airbo.BoardActivityGrid.init();
  }
});
