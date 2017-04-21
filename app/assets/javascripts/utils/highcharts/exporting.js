var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.Exporting = (function(){

  function defaultExportingConfig() {
    return {
      enabled: false,
      sourceHeight: 650,
      sourceWidth: 1024,
      chartOptions: {
        chart: {
          style: {
            fontFamily: 'Tahoma'
          }
        }
      },
      buttons: {
        contextButton: {
          menuItems: null
        }
      }
    };
  }

  return {
     defaultExportingConfig:  defaultExportingConfig
  };
}());
