var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};
Airbo.Highcharts.CustomTooltips = Airbo.Highcharts.CustomTooltips || {};

Airbo.Highcharts.CustomTooltips.SharedTooltipWithPercentOfWhole = (function(){
  var $chart;
  var data;

  function render(chart) {
    $chart = chart;

    return $.extend(true, {}, Airbo.Highcharts.Tooltip.defaultTooltipConfigs($chart), {
      shared: true,
      formatter: function() {
        data = this;
        return customFormat();
      }
    });
  }

  function customFormat() {
    return header() + body() + footer();
  }

  function header() {
    return Airbo.Highcharts.Tooltip.defaultTooltipHeaderComponent(data, $chart.data("intervalType"));
  }

  function footer() {
    var singleSeriesData = data.points[0];
    return Airbo.Highcharts.Tooltip.defaultTooltipFooterComponent(singleSeriesData, $chart);
  }

  function body() {
    var body = "";
    $.each(data.points, function(i, pointData) {
      body += tooltipTableRowComponent(pointData, "point");
    });

    body += tooltipTableRowComponent(data, "total");

    return "</br><table border='0'><tbody>" + body + "</tbody></table>";
  }

  function tooltipTableRowComponent(data, type, percentColumnType) {
    var options = getRowOptions(data, type);

    return "<tr style='min-width:200px'><td style='color:#33445c;font-size:15px;font-weight:bold;" + options.borderBottom + "'>" + options.colorIndicator + options.name + "</td><td style='color:#33445c;font-size:13px;text-align:right;" + options.borderBottom + "'>" + options.data + "</td><td style='color:#33445c;font-size:13px;text-align:right;" + options.borderBottom + "'>" + options.percentage + "%</td></tr>";
  }

  function getRowOptions(data, type) {
    if (type === "total") {
      return {
        color: "#33445c",
        name: "Total",
        data: data.points[0].total,
        percentage: 100,
        borderBottom: "border-bottom:none;",
        colorIndicator: "<span style='color:#fff'>\u25CF </span>"
      };
    } else {
      return {
        color: data.color,
        name: data.series.name,
        data: Highcharts.numberFormat(data.y, 0, '', ','),
        percentage: percentColumn(data),
        colorIndicator: "<span style='color:" + data.color + "'>\u25CF </span>"
      };
    }
  }

  function percentColumn(pointData, type) {
    return Math.round(pointData.percentage);
  }

  return {
    render: render
  };

}());
