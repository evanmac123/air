var Airbo = window.Airbo || {};

Airbo.CustomerSuccessKpi = (function(){


function init(){
  Airbo.Utils.KpiReportDateFilter.init();
  Airbo.Utils.StickyTable.init();
}

return {
 init: init
};

})()
$(function(){
  if(Airbo.Utils.supportsFeatureByPresenceOfSelector(".customer-success.kpi-dashboard")){
    Airbo.CustomerSuccessKpi.init();
  }
});
