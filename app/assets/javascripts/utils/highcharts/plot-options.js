var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.PlotOptions = (function() {
  function defaultPlotOptions($chart) {
    return {
      series: {
        lineWidth: 3,
        pointInterval: pointInterval($chart.data("interval_type")),
        pointIntervalUnit: pointIntervalUnit($chart.data("interval_type"))
      },
      line: {
        marker: {
          fillColor: "#FFFFFF",
          radius: 4.5,
          lineWidth: 2,
          lineColor: null // inherit from series
        }
      },
      shadow: false,
      marker: {
        radius: 5
      },
      column: {
        pointPadding: 0.05,
        borderWidth: 0,
        groupPadding: 0.05
      }
    };
  }

  function pointInterval(timeUnit) {
    if (timeUnit === "quarter") {
      //quarter in milliseconds
      return 24 * 3600 * 1000 * 30 * 4;
    } else {
      //when used with pointIntervalUnit, this number refers to n units
      return 1;
    }
  }

  function pointIntervalUnit(timeUnit) {
    if (timeUnit === "quarter") {
      return null;
    } else {
      return timeUnit;
    }
  }

  return {
    defaultPlotOptions: defaultPlotOptions
  };
})();
