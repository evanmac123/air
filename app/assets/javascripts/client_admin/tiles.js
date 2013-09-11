$(document).ready(function() {

  var add_csrf_protection = function(params) {
    var csrf_param = $('meta[name=csrf-param]').attr('content'),
        csrf_token = $('meta[name=csrf-token]').attr('content');

    params[csrf_param] = csrf_token;
    return params;
  };

  var showFeedback = function(feedback) {
    $('.update-digest-spinner').hide();
    $('#digest-status-messages #feedback').html(feedback).fadeIn('slow');
  };

  var sendOnDayChange = function() {
    var $sendOn = $(this);
    var sendOnVal = $sendOn.val();

    var sendOnTime = sendOnVal == 'Never' ? null : 'at noon, ';
    $('#digest-send-on-time').html(sendOnTime);

    var params = { send_on: sendOnVal, _method: 'put' };
    params = add_csrf_protection(params);

    $('#update-send-on-spinner').show();
    $.post($sendOn.attr('data-action'), params, showFeedback);
  };

  var sendToChange = function() {
    var sendTo = $(this).val();
    var path = $(this).attr('data-action');

    var params = {_method: 'put', send_to: sendTo};
    params = add_csrf_protection(params);

    $('#update-send-to-spinner').show();
    $.post(path, params, showFeedback);
  };

  var followUpChange = function() {
    var followUp = $(this).val();
    var path = $(this).attr('data-action');

    var params = {_method: 'put', follow_up: followUp};
    params = add_csrf_protection(params);

    $('#update-follow-up-spinner').show();
    $.post(path, params, showFeedback);
  };

  // -------------------------------------------------------

  $('#tile-manager-tabs, #tile-reports-tabs').tabs();

  $('#digest_send_on').change(sendOnDayChange);
  $('#digest_send_to').change(sendToChange);
  $('#digest_follow_up').change(followUpChange);
});
