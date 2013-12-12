conversionResponseCallback = (event, data) ->
  if data.status == 'success'
    window.location.href = "/activity"

$('#guest_conversion_form').on('ajax:success', conversionResponseCallback)
