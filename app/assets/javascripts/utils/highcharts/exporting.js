var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.Exporting = (function(){

  function defaultExportingConfig($chart) {
    return {
      enabled: false,
      sourceHeight: 650,
      sourceWidth: 1024,
      chartOptions: {
        chart: {
          marginTop: 100,
          style: {
            fontFamily: 'Tahoma'
          }
        },
        title: {
          text: $chart.data("title"),
          align: "left",
          style: {
            color: $chart.data("chartHeaderColor"),
            fontWeight: "bold"
          }
        },
        subtitle: {
          text: $chart.data("subtitle"),
          align: "left",
          style: {
            color: $chart.data("chartSubHeaderColor"),
            fontSize: "16px"
          }
        }
      }
    };
  }

  return {
     defaultExportingConfig:  defaultExportingConfig
  };
}());
