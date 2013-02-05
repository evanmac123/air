$(document).ready(function() {
  $('#chart_start_date, #chart_end_date').datepicker();

  // This is the "usual" case
  $('#chart_interval, #chart_start_date').change(function() {
    if ($('#chart_interval').val() == 'Hourly')
      $('#chart_end_date').val($('#chart_start_date').val());
  });

  // This can happen, and since we want to keep these dates the same if 'hourly'...
  $('#chart_end_date').change(function() {
    if ($('#chart_interval').val() == 'Hourly')
      $('#chart_start_date').val($('#chart_end_date').val());
  });

  // Chart parameters are initialized in controller's 'show' action (e.g. Daily view for acts and users for the previous month)
  //  => submit the form with those params when the page is initially loaded.
  $('#activity-chart').submit();
});