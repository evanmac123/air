var Airbo = window.Airbo || {};

Airbo.SurveyTable = (function(){
  function init(){
    new Tablesort(document.getElementById('survey_table'));
  }
  return {
    init: init
  };
}());

$(function(){
  if (Airbo.Utils.isAtPage(Airbo.Utils.Pages.SURVEY_TABLE)) {
    Airbo.SurveyTable.init();
  }
});
