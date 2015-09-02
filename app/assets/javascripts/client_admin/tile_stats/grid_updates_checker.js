var Airbo = window.Airbo || {};

Airbo.GridUpdatesChecker = (function(){
  var continueRequests = true,
      timeoutID,
      interval = 10000, // ms
      checkLink,
      tileGridSectionSel = ".tile_grid_section",
      tileGridSection,
      tableSel = "#tile_stats_grid table",
      table,
      newRecordsSectionSel = ".new_records",
      startTimeInMs;

  function findNewRecordsSection() {
    return table.find(newRecordsSectionSel);
  }

  function findOrCreateNewRecordsSection(){
    newRecordsSection = findNewRecordsSection();
    if(newRecordsSection.length == 0) {
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
    //console.log(timeoutID);
    $.ajax({
      url: checkLink,
      data: {start_time_in_ms: startTimeInMs},
      success: ajaxResponse(),
      dataType: "json"
    });
    if(continueRequests){
      start();
    }
  }

  function start() {
    timeoutID = window.setTimeout(checkForUpdate, interval);
  }

  function stop() {
    if(timeoutID) {
      window.clearTimeout(timeoutID);
    }
  }

  function updateStartTime() {
    startTimeInMs = Date.now();
  }

  function init() {
    tileGridSection = $(tileGridSectionSel);
    checkLink = tileGridSection.data('updates-checker-link');
    table = $(tableSel);
    updateStartTime();
    return this;
  }

  return {
    init: init,
    start: start,
    updateStartTime: updateStartTime
  };
}());
