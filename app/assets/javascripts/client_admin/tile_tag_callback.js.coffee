tileTagCallback = (listSelector) ->
  (data) ->
    _data = $.parseJSON(data)
    $(listSelector).replaceWith(_data.new_list_html)

window.tileTagCallback = tileTagCallback
