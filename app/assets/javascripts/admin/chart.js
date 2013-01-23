$(document).ready(function() {
  $('#chart_start_date, #chart_end_date').datepicker();

  $('#chart_interval, #chart_start_date').change(function() {
    if ($('#chart_interval').val() == 'Hourly')
      $('#chart_end_date').val($('#chart_start_date').val());
  });
});