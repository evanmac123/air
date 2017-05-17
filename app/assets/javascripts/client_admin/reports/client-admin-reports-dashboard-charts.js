var Airbo = window.Airbo || {};

Airbo.ClientAdminReportsDashboardCharts = (function(){
  var reportSel = ".report-container";
  var $parentModule;

  function buildChart($chart, $module) {
    $parentModule = $module;

    $chart.highcharts(Airbo.Utils.HighchartsBase.chartTemplate($chart));
    requestChart($chart);
  }

  function chartStrongParams($chart) {
    return {
      chart_params: {
        chart_type: $chart.data("chartType"),
        interval_type: $chart.data("intervalType"),
        requested_series_list: $chart.data("requestedSeriesList"),
        start_date: $($parentModule).data("startDate"),
        end_date: $($parentModule).data("endDate"),
        demo_id: $(reportSel).data("currentDemoId")
      }
    };
  }

  function requestChart($chart) {
    $chart.highcharts().showLoading(Airbo.Utils.HighchartsBase.loadingContent());

    $.ajax({
      url: $chart.data("path"),
      type: "GET",
      data: chartStrongParams($chart),
      dataType: "json",
      success: function(response, status, xhr) {
        var chartData = response.data.attributes;
        convertToJsDates(chartData.series);

        var chartAttrs = $.extend(true, {}, Airbo.Utils.HighchartsBase.chartTemplate($chart, chartData), chartData);

        $chart.highcharts(chartAttrs);
        initExport($chart);
        downloadButton($chart).show();

        showChartControls($chart);

        if (chartHasNoData($chart.highcharts().series)) {
          manageNoData($chart);
        }
      },
      fail: function(response, status, xhr) {
      }
    });
  }

  function downloadButton($chart) {
    return $("#download-" + $chart.attr("id"));
  }

  function initExport($chart) {
    var exportButton = downloadButton($chart);
    exportButton.on("click", function(e) {
      e.preventDefault();
      $chart.highcharts().exportChart({
        type: "application/pdf",
        filename: formateExportFilename($chart)
      });
    });
  }

  function formateExportFilename($chart) {
    var parsedTitle = $chart.data("title").replace(/ /g,"_");
    var snakeDate = moment().format('MM_DD_YYYY');

    return "Airbo_" + parsedTitle + "_" + snakeDate;
  }

  function showChartControls($chart) {
    $chart.parents(".chart-group-container").children(".chart-controls-group").fadeIn();
  }

  function chartHasNoData(seriesList) {
    var data = $.map(seriesList, function(series) {
      return series.data;
    });

    return data.length === 0;
  }

  function manageNoData($chart) {
    $chart.highcharts().showLoading(Airbo.Utils.HighchartsBase.noDataMessage($chart));
  }

  function convertToJsDates(allSeries) {
    $.each(allSeries, function(seriesIdx, series) {
      $.each(series.data, function(plotIdx, plot) {
        plot[0] = Date.parse(plot[0]);
      });
    });
  }

  function getChartWithTarget($node, closestNodeWithTarget) {
    var chartSel = $node.closest(closestNodeWithTarget).data("chartTarget");
    return $(chartSel);
  }

  function chartDateChange() {
    $(".chart-interval-change").on("click", function(e) {
      e.preventDefault();

      if ($(this).hasClass("tabs-component-active")) {
        return false;
      }

      Airbo.ClientAdminReportsUtils.switchActiveTab($(this));

      var $chart = getChartWithTarget($(this), ".chart-interval-opts");
      var intervalType = $(this).data("interval");

      $chart.data("intervalType", intervalType);

      requestChart($chart);
    });
  }

  function init() {
    chartDateChange();
  }

  return {
    buildChart: buildChart,
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".client_admin-reports")) {
    Airbo.ClientAdminReportsDashboardCharts.init();
  }
});
