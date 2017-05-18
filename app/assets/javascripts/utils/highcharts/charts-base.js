var Airbo = window.Airbo || {};

Airbo.HighchartsBase = (function(){

  function chartTemplate($chart, data) {
    var template;
    var requestedTemplate = $chart.data("chartTemplate");

    if (requestedTemplate === "stackedBarGraph") {
      template = Airbo.Highcharts.stackedBarGraphTemplate($chart);
    } else if (requestedTemplate === "groupedBarGraph") {
      template = Airbo.Highcharts.groupedBarGraphTemplate($chart);
    } else if (requestedTemplate === "loginActivityTilesDigest") {
      template = Airbo.Highcharts.loginActivityTilesDigestTemplate($chart, data);
    }

    return $.extend(true, {}, Airbo.Highcharts.defaultTemplate($chart), template);
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

  function seriesIsIncomplete(pointValue, intervalType) {
    var startDate = moment(pointValue).utc();
    var endDate = startDate.endOf(intervalType).toDate();

    return moment().isBefore(endDate);
  }

  function dataPointIsLast(pointValue, series) {
    return pointValue === lastPointInSeries(series);
  }

  function lastPointInSeries(series) {
    if (series.data.length > 0) {
      return series.data[series.data.length -1].x;
    }
  }

  function specifyIncompleteZones(allSeries, intervalType) {
    $.each(allSeries, function(seriesIdx, series) {
      if (series.data.length > 0) {
        var lastDataPoint = series.data[series.data.length - 1];
        var penultimateDataPoint = series.data[series.data.length - 2];
        if (seriesIsIncomplete(lastDataPoint[0], intervalType)) {
          series.zoneAxis = 'x';
          series.zones = [
            { value: penultimateDataPoint[0] },
            { dashStyle: 'dash' }
          ];
        }
      }
    });
  }

  function convertSeriesToJsDates(allSeries) {
    $.each(allSeries, function(seriesIdx, series) {
      $.each(series.data, function(plotIdx, plot) {
        plot[0] = Date.parse(plot[0]);
      });
    });
  }

  return {
    chartTemplate: chartTemplate,
    loadingContent: loadingContent,
    noDataMessage: noDataMessage,
    axisMax: axisMax,
    dataPointIsLast: dataPointIsLast,
    seriesIsIncomplete: seriesIsIncomplete,
    specifyIncompleteZones: specifyIncompleteZones,
    convertSeriesToJsDates: convertSeriesToJsDates
  };

}());
