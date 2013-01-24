$(document).ready(function() {
  $('#chart_start_date, #chart_end_date').datepicker();

  // This is the most "usual" case
  $('#chart_interval, #chart_start_date').change(function() {
    if ($('#chart_interval').val() == 'Hourly')
      $('#chart_end_date').val($('#chart_start_date').val());
  });

  // This can happen, and since we want to keep these dates the same if 'hourly'...
  $('#chart_end_date').change(function() {
    if ($('#chart_interval').val() == 'Hourly')
      $('#chart_start_date').val($('#chart_end_date').val());
  });
});