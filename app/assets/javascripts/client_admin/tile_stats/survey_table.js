var Airbo = window.Airbo || {};

Airbo.SurveyTable = (function(){
  function init(){
    table = document.getElementById('survey_table');
    if(table){
      new Tablesort(table);
    }
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
