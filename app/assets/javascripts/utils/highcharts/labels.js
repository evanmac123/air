var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.Labels = (function(){

  function defaultLabelFormat($chart) {
    var intervalType = $chart.data("intervalType");

    if (intervalType === 'quarter') {
      return '{value: %Q}';
    } else if (intervalType === 'year') {
      return '{value: %Y}';
    } else {
      return '{value: %b %Y}';
    }
  }

  return {
    defaultLabelFormat: defaultLabelFormat
  };

}());
