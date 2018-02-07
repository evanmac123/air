var Airbo = window.Airbo || {};

Airbo.TileStatsChart = (function() {
  function init(data) {
    $chart = $("#" + data.chartId);
    $chart.data("seriesNames", data.chartSeriesNames);
    $chart.data("intervalType", "hour");

    var template = $.extend(
      true,
      {},
      Airbo.Highcharts.defaultTemplate($chart),
      Airbo.Highcharts.tileActivityTemplate($chart, data)
    );

    var chartData = data.tileActivitySeries;
    Airbo.HighchartsBase.convertSeriesToJsDates(chartData.series);

    var chartAttrs = $.extend(true, {}, template, chartData);
    $chart.highcharts(chartAttrs);
  }

  return {
    init: init
  };
})();
