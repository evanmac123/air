var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.Tooltip = (function(){

  function defaultTooltip($chart) {
    return $.extend(true, {}, defaultTooltipConfigs($chart), {
      formatter: function() {
        return tooltipFormatter(this, $chart);
      }
    });
  }

  function defaultTooltipConfigs($chart) {
    return {
      valueSuffix: null,
      useHTML: true,
      backgroundColor: "white",
      hideDelay: 200
    };
  }

  function defaultTooltipHeaderComponent(data, intervalType) {
    var dateFormat = getDateFormat(data.x, intervalType);
    var color = getColor(data);

    return "<div style='text-align:center;margin-bottom:15px;margin-top:5px;'><span style='border-bottom: solid 1px " + color + ";padding:5px;color:#33445c;font-size:14px;'>" + dateFormat + "</span></div>";
  }

  function defaultTooltipFooterComponent(data, $chart) {
    if (Airbo.HighchartsBase.dataPointIsLast(data.x, data.series) && Airbo.HighchartsBase.seriesIsIncomplete(data.x, $chart.data("intervalType"))) {

      return "<div style='border-top: dashed 1px #48bfff;margin-top: 15px;padding-top:7px;color:#33445c;font-weight:bold;'>Incomplete " + $chart.data("intervalType") + "</div>";
    } else {
      return "";
    }
  }

  function getDateFormat(timestamp, intervalType) {
    var date = new Date(timestamp);
    if (intervalType === "quarter") {
      return Highcharts.dateFormat('%Q', date);
    } else if (intervalType === "week") {
      return Highcharts.dateFormat('Week of %b %d, %Y', date);
    } else if (intervalType === "hour") {
      var lowerHour = moment(date).local();
      var upperHour = moment(date).local().add({ hours: 1 });

      return lowerHour.format("h:00a-") + upperHour.format("h:00a ") + lowerHour.format("on MMM D");
    } else {
      return Highcharts.dateFormat('%B, %Y', date);
    }
  }

  function getColor(data) {
    if (data.color) {
      return data.color;
    } else if (data.points[0]) {
      return data.points[0].color;
    }
  }

  return {
    defaultTooltipConfigs: defaultTooltipConfigs,
    defaultTooltipHeaderComponent: defaultTooltipHeaderComponent,
    defaultTooltipFooterComponent: defaultTooltipFooterComponent,
  };

}());
