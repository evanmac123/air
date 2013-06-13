$(document).ready(function() {

  $(document).ajaxStart(function() { $('#show-user-spinner').show(); })
             .ajaxStop(function()  { $('#show-user-spinner').hide(); });

  var add_csrf_protection = function(params) {
    var csrf_param = $('meta[name=csrf-param]').attr('content'),
        csrf_token = $('meta[name=csrf-token]').attr('content');

    params[csrf_param] = csrf_token;
    return params;
  };

  var sendOnDayChange = function() {
    var $sendOn = $(this);
    var sendOnVal = $sendOn.val();

    var params = { send_on: sendOnVal, _method: 'put' };
    params = add_csrf_protection(params);

    $.post($sendOn.attr('data-action'), params);
  };

  // -------------------------------------------------------

  $('#tile-manager-tabs').tabs();

  $('#digest_send_on').change(sendOnDayChange);
});
