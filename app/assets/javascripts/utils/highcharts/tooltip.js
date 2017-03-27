var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.Tooltip = (function(){

  function defaultTooltip($chart) {
    return {
      valueSuffix: null,
      useHTML: true,
      backgroundColor: "white",
      style: {
        padding: 8,
        fontSize: 14
      },
      headerFormat: pointTooltipHeaderFormat($chart.data("intervalType")),
      pointFormatter: function() {
        return pointFormatter(this);
      }
    };
  }

  function pointFormatter(point) {
    var sign = "";
    var percentInc;
    var prevY = point.series.yData[point.index-1];

    if (prevY) {
      percentInc = Math.round(100.0 * (point.y - prevY) / prevY);
    } else {
      if (point.y === 0) {
        percentInc = 0;
      } else {
        percentInc = 100;
      }
    }

    if (percentInc >= 0) {
      sign = "+";
    }

    return "<p style='margin-bottom:0;margin-top:15px;padding:0 5px;color:#33445c;min-width:145px;font-size:16px;font-weight:bold;'>" + Highcharts.numberFormat(point.y, 0, '', ',') +
             " <span style='color:#0489d1;float:right;'>" + sign + percentInc + "%</span>" +
           "</p>";
  }

  function pointTooltipHeaderFormat(intervalType) {
    var format;
    if (intervalType === "quarter") {
      format = "{point.key: %Q}";
    } else if (intervalType === "week") {
      format = "{point.key: Week of %b %d, %Y}";
    } else {
      format = "{point.key}";
    }

    return "<div style='text-align:center;'><span style='border-bottom: solid 1px {point.color};padding:5px;color:#33445c;font-size:14px;'>" + format + "</span></div>";
  }

  return {
    defaultTooltip: defaultTooltip
  };

}());
