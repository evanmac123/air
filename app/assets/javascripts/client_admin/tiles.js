$(document).ready(function() {
  // Initial state (specified in the view): checkbox: unchecked (Rails default) ; select_box: disabled
  $('#send_follow_up').click(function() { $("#follow_up_day").prop("disabled", ! (this.checked)); });

  $('#tile-manager-tabs, #tile-reports-tabs').tabs();
});
