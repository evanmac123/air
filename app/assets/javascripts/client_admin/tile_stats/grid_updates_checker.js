var Airbo = window.Airbo || {};

Airbo.GridUpdatesChecker = (function(){
  var timeoutID;
  var checkLink;
  var tileGridSection;
  var table;
  var startTimeInMs;

  var interval = 5000;
  var tileGridSectionSel = ".tile_grid_section";
  var tableSel = "#tile_stats_grid table";
  var newRecordsSectionSel = ".new_records";

  function findNewRecordsSection() {
    return table.find(newRecordsSectionSel);
  }

  function findOrCreateNewRecordsSection() {
    newRecordsSection = findNewRecordsSection();
    if (newRecordsSection.length === 0) {
      table.find('thead').after("<td class='new_records' colspan='5'></td>");
      newRecordsSection = findNewRecordsSection();
    }

    return newRecordsSection;
  }

  function removeNewRecordsSection() {
    findNewRecordsSection().remove();
  }

  function ajaxResponse() {
    return function (data){
      console.log(data.text);
      if(data.text.length > 0) {
        findOrCreateNewRecordsSection().html(data.text);
      } else {
        removeNewRecordsSection();
      }
    };
  }

  function checkForUpdate() {
    $.ajax({
      url: checkLink,
      data: { start_time_in_ms: startTimeInMs },
      success: ajaxResponse(),
      dataType: "json"
    });
  }

  function start() {
    stopChecker();
    timeoutID = window.setInterval(checkForUpdate, interval);
  }

  function restart() {
    stopChecker();
    initVars();
    start();
  }

  function stopChecker() {
    window.clearInterval(timeoutID);
  }

  function updateStartTime() {
    startTimeInMs = Date.now();
  }

  function initVars() {
    tileGridSection = $(tileGridSectionSel);
    checkLink = tileGridSection.data('updates-checker-link');
    table = $(tableSel);
  }

  function initEvents() {
    $(document).on("click", newRecordsSectionSel, function(e) {
      e.preventDefault();
      $("#grid_type_select").find('option').eq(0).prop('selected', true);
      $("#grid_type_select").trigger("change", true);
      updateStartTime();
    });
  }

  function init() {
    initVars();
    updateStartTime();
    initEvents();
    return this;
  }

  return {
    init: init,
    start: start,
    stopChecker: stopChecker,
    restart: restart
  };
}());
