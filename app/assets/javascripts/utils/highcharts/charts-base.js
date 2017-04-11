var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.HighchartsBase = (function(){

  function chartTemplate($chart, data) {
    var template;
    var requestedTemplate = $chart.data("chartTemplate");

    if (requestedTemplate === "stackedBarGraph") {
      template = Airbo.Utils.Highcharts.stackedBarGraphTemplate($chart);
    } else if (requestedTemplate === "groupedBarGraph") {
      template = Airbo.Utils.Highcharts.groupedBarGraphTemplate($chart);
    } else if (requestedTemplate === "loginActivityTilesDigest") {
      template = Airbo.Utils.Highcharts.loginActivityTilesDigestTemplate($chart, data);
    }

    return $.extend(true, {}, Airbo.Utils.Highcharts.defaultTemplate($chart), template);
  }

  function loadingContent() {
    return '<i class="fa fa-2x fa-spinner fa-spin fa-fw"></i>';
  }

  function noDataMessage($chart) {
    return formattedNoDataMessage($chart.data("noDataMessage"));
  }

  function formattedNoDataMessage(message) {
    if (message) {
      return "<span class='highcharts-loading-inner'>" + message + "</span>";
    } else {
      return "There is no data for this time period.";
    }
  }

  function axisMax(axisData) {
    var values = $.map(axisData, function(point) {
      return point[1];
    });

    return Math.max.apply(null, values);
  }

  return {
    chartTemplate: chartTemplate,
    loadingContent: loadingContent,
    noDataMessage: noDataMessage,
    axisMax: axisMax
  };

}());
