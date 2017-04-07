var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.Legend = (function(){

  function defaultLegend($chart) {
    return {
      enabled: true,
      verticalAlign: 'bottom',
      align:'left',
      floating: true,
      y: 40,
      backgroundColor: "#fff",
      borderWidth: 0,
      shadow: false,
      itemStyle: {
        "color": "#33445c"
      }
    };
  }

  return {
    defaultLegend: defaultLegend
  };

}());
