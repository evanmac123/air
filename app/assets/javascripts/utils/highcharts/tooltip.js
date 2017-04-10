var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.Tooltip = (function(){

  function defaultTooltip($chart) {
    return {
      shared: $chart.data("sharedTooltip"),
      valueSuffix: null,
      useHTML: true,
      backgroundColor: "white",
      hideDelay: 200,
      style: {
        padding: 8,
        fontSize: 14
      },
      formatter: function() {
        return tooltipFormatter(this, $chart);
      }
    };
  }

  function tooltipFormatter(data, $chart) {
    var header = tooltipHeaderFormat(data, $chart.data("intervalType"));
    var body   = tooltipPointsFormat(data, $chart);

    return header + body;
  }

  function tooltipHeaderFormat(data, intervalType) {
    var dateFormat = getDateFormat(data.x, intervalType);
    var color = getColor(data);

    return "<div style='text-align:center;margin:5px 0;'><span style='border-bottom: solid 1px " + color + ";padding:5px;color:#33445c;font-size:14px;'>" + dateFormat + "</span></div>";
  }

  function tooltipPointsFormat(data, $chart) {
    if ($chart.data("sharedTooltip")) {
      return sharedPointFormatter(data, $chart);
    } else {
      return singlePointFormatter(data, "percentIncrease");
    }
  }

  function sharedPointFormatter(data, $chart) {
    var body = "";
    var percentColumnType = $chart.data("tooltipPercentColumnType");

    $.each(data.points, function(i, pointData) {
      body += tooltipTableRow(pointData, "point", percentColumnType);
    });

    if (showTotalsRow(percentColumnType)) {
      body += tooltipTableRow(data, "total");
    }

    return "</br><table border='0'><tbody>" + body + "</tbody></table>";
  }

  function tooltipTableRow(data, type, percentColumnType) {
    var options = getRowOptions(data, type, percentColumnType);

    return "<tr><td style='color:" + options.color + ";font-size:14px;font-weight:bold;" + options.borderBottom + "'>" + options.name + "</td><td style='color:#33445c;font-size:12px;font-weight:bold;text-align:right;" + options.borderBottom + "'>" + options.data + "</td><td style='color:#33445c;font-size:12px;font-weight:bold;text-align:right;" + options.borderBottom + "'>" + options.percentage + "%</td></tr>";
  }

  function getRowOptions(data, type, percentColumnType) {
    if (type === "total") {
      return {
        color: "#33445c",
        name: "Total",
        data: data.points[0].total,
        percentage: 100,
        borderBottom: "border-bottom:none;"
      };
    } else {
      return {
        color: data.color,
        name: data.series.name,
        data: Highcharts.numberFormat(data.y, 0, '', ','),
        percentage: percentColumn(data, percentColumnType)
      };
    }
  }

  function showTotalsRow(type) {
    if (type === "percentageOfTotal") {
      return true;
    }
  }

  function percentColumn(pointData, type) {
    if (type === "percentageOfTotal") {
      return Math.round(pointData.percentage);
    }
  }

  function singlePointFormatter(data, secondaryData) {
    var secondaryDataHtml;

    if (secondaryData === "percentIncrease") {
      secondaryDataHtml = "<span style='color:#48bfff;float:right;'>" + percentIncrease(data) + "%</span>";
    }

    return "<p style='margin-bottom:0;padding:0 5px;color:" + data.color + ";min-width:145px;font-size:14px;font-weight:bold;'>" + data.series.name + "</p><p style='margin:0;padding:0 5px;color:#33445c;min-width:145px;font-size:14px;font-weight:bold;'>" + Highcharts.numberFormat(data.y, 0, '', ',') + secondaryDataHtml + "</p>";
  }

  function percentIncrease(data) {
    var percentInc;
    var point = data.point;
    var series = data.series;

    var prevY = series.yData[point.index-1];

    if (prevY) {
      percentInc = Math.round(100.0 * (point.y - prevY) / prevY);
    } else {
      percentInc = 0;
    }

    if (percentInc >= 0) {
      percentInc = "+" + percentInc;
    }

    return percentInc;
  }

  function getDateFormat(timestamp, intervalType) {
    var date = new Date(timestamp);
    if (intervalType === "quarter") {
      return Highcharts.dateFormat('%Q', date);
    } else if (intervalType === "week") {
      return Highcharts.dateFormat('Week of %b %d, %Y', date);
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
    defaultTooltip: defaultTooltip
  };

}());
