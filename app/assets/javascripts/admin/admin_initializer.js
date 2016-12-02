var Airbo = window.Airbo || {};


Airbo.SiteAdminInitializer = ( function(){

  function initBoardDeleter(){
    $("#delete-board").on("click", function() {
      Airbo.Utils.Modals.trigger("#delete-board-modal", 'open');
    });
  }

  function initModalCloser(){

    Airbo.Utils.Modals.bindClose();
  }

  function initBoardsAndOrgs(){
    Airbo.BoardsAndOrganizationMgr.init();
  }


  function initZurbFoundation(){
    //FIXME foundation.min includes foundation.forms js which hijacks forms and
    //hides elements like checkboxes. if we need to use any foundation js then we
    //will need re-display any hijacked form elements
    //$(document).foundation();
  }

  function initKpiTooltips(){
    $("span.kpi-tooltip").tooltipster(
      {
        theme: "tooltipster-shadow",
      }
    );
  }


  function init(){
    initBoardDeleter();
    initModalCloser();
    initBoardsAndOrgs();
    initKpiTooltips();
  }


  return {
   init: init
  }

})();



$(function(){
  Airbo.SiteAdminInitializer.init();
});

