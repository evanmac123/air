var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.Labels = (function(){

  function defaultLabelFormat($chart) {
    var intervalType = $chart.data("intervalType");

    if (intervalType === 'day' || intervalType === 'week') {
      return '{value: %b %d}';
    } else if (intervalType === 'month') {
      return '{value: %b %Y}';
    } else if (intervalType === 'quarter') {
      return '{value: %Q}';
    } else if (intervalType === 'year') {
      return '{value: %Y}';
    }
  }

  return {
    defaultLabelFormat: defaultLabelFormat
  };

}());
