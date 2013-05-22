$(document).ready(function() {
  var sendOnDayChange = function() {
    alert('Day Changed');
  };

  var sendNow = function() {
    alert('Send Now');
  };

  // -------------------------------------------------------

  $('#tile-manager-tabs').tabs();

  $('#digest_send_on').change(sendOnDayChange);
  $('#digest-email-yes input:submit').click(sendNow);
});
