var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};
Airbo.Highcharts.CustomTooltips = Airbo.Highcharts.CustomTooltips || {};

Airbo.Highcharts.CustomTooltips.SharedTooltipWithPercentChange = (function(){
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
    $.each(data.points, function(i, point) {

      body += defaultSeriesNameComponent(point);

      body += percentChangeComponent(point, $chart.data("intervalType"));

      body += defaultCountComponent(point);

      if (i < data.points.length - 1) {
        body += seperatorLineComponent();
      }
    });

    return body;
  }

  function defaultSeriesNameComponent(data) {
    return "<p style='margin:0;color:#33445c;min-width:250px;font-size:15px;font-weight:bold;'><span style='color:" + data.color + "'>\u25CF </span>" + data.series.name + "</p>";
  }

  function percentChangeComponent(data, intervalType) {
    var props = percentChangeAttrs(data);

    if (props.decoratedChange) {
      return "<span style='color:" + props.color + ";font-weight:bold;float:right;'>" + props.decoratedChange + " from last " + intervalType + "</span>";
    } else {
      return "";
    }
  }

  function defaultCountComponent(data) {
    return "<span style='margin-left:12px;color:#33445c;font-size:13px;'>" + Highcharts.numberFormat(data.y, 0, '', ',') + "</span>";
  }

  function seperatorLineComponent() {
    return "<div style='height:1px;background-color:#eaeced; margin: 10px 0;'></div>";
  }

  function percentChangeAttrs(data) {
    var percentChange;
    var point = data.point;
    var series = data.series;
    var prevY = previousYPoint(series, point);

    if (pointIsNotFirst(point)) {
      percentChange = Math.round(100.0 * (point.y - prevY) / prevY);
    }

    return decoratePercentChange(percentChange, point, prevY);
  }

  function decoratePercentChange(percentChange, point, prevY) {
    var color;
    var decoratedChange;

    if (percentChange >= 0) {
      color = "#4fd4c0";
    } else {
      color = "#BC4C40";
    }

    if (percentChange !== undefined) {
      if (percentChange === Infinity) {
        decoratedChange = "Up " + Highcharts.numberFormat(point.y, 0, '', ',');
      } else if(percentChange >= 0) {
        if (percentChange >= 5000) {
          decoratedChange = "+" + Highcharts.numberFormat(Math.round(point.y / prevY), 0, '', ',') + "X";
        } else {
          decoratedChange = "+" + Highcharts.numberFormat(percentChange, 0, '', ',') + "%";
        }
      } else {
        decoratedChange = percentChange + "%";
      }
    }

    return {
      decoratedChange: decoratedChange,
      color: color
    };
  }

  function previousYPoint(series, curPoint) {
    return series.yData[curPoint.index-1];
  }

  function pointIsNotFirst(point) {
    return point.index > 0;
  }

  return {
    render: render
  };

}());
