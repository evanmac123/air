var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.Legend = (function() {
  function defaultLegend($chart) {
    return {
      enabled: true,
      verticalAlign: "bottom",
      align: "left",
      floating: false,
      y: 40,
      backgroundColor: "#fff",
      borderWidth: 0,
      shadow: false,
      itemStyle: {
        color: "#33445c"
      }
    };
  }

  return {
    defaultLegend: defaultLegend
  };
})();
