var Airbo = window.Airbo || {};

Airbo.ClientAdminSummaryReportsDashboardCharts = (function(){

  function buildChart($chart, $module) {
    var $parentModule = $module;

    $chart.highcharts(Airbo.HighchartsBase.chartTemplate($chart));
    requestChart($chart, $parentModule);
  }

  function requestChart($chart, $parentModule) {
    $chart.highcharts().showLoading(Airbo.HighchartsBase.loadingContent());

    $.ajax({
      url: $chart.data("path"),
      type: "GET",
      data: chartStrongParams($chart, $parentModule),
      dataType: "json",
      success: function(response, status, xhr) {
        var chartData = response.data.attributes;

        Airbo.HighchartsBase.convertSeriesToJsDates(chartData.series);
        Airbo.HighchartsBase.specifyIncompleteZones(chartData.series, $chart.data("intervalType"));

        var chartAttrs = $.extend(true, {}, Airbo.HighchartsBase.chartTemplate($chart, chartData), chartData);
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

  function chartStrongParams($chart, $parentModule) {
    return {
      chart_params: {
        chart_type: $chart.data("chartType"),
        interval_type: $chart.data("intervalType"),
        requested_series_list: $chart.data("requestedSeriesList"),
        start_date: $parentModule.data("startDate"),
        end_date: $parentModule.data("endDate"),
        demo_id: Airbo.ClientAdminReportsUtils.reportsBoardId()
      }
    };
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
    $chart.highcharts().showLoading(Airbo.HighchartsBase.noDataMessage($chart));
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
      var $parentModule = $chart.parents(".summary-report-module");
      var intervalType = $(this).data("interval");

      $chart.data("intervalType", intervalType);

      requestChart($chart, $parentModule);
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
    Airbo.ClientAdminSummaryReportsDashboardCharts.init();
  }
});
