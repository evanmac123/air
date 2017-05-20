var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.Labels = (function(){

  function defaultLabelFormatter(label, $chart) {
    return getDateFormat(label.value, $chart.data("intervalType"));
  }

  function getDateFormat(timestamp, intervalType) {
    var date = new Date(timestamp);
    if (intervalType === 'quarter') {
      return Highcharts.dateFormat('%Q', date);
    } else if (intervalType === 'year') {
      return Highcharts.dateFormat('%Y', date);
    } else if (intervalType === 'month') {
      return Highcharts.dateFormat('%b %Y', date);
    } else if (intervalType === 'week') {
      return Highcharts.dateFormat('%m/%d/%y', date);
    }
  }

  return {
    defaultLabelFormatter: defaultLabelFormatter
  };

}());
