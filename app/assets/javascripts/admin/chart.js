$(document).ready(function() {
  $('#start_date, #end_date').datepicker();

  $('#interval').change(function() {
    $('#end_date').val($('#start_date').val());
  });
});