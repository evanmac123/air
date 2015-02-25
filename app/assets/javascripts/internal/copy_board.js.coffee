window.copyBoard = ->
  $("#copy_board_link").click ->
    copyLink = $(@)

    $.post(copyLink.attr('data-url'), {},
      (data) ->
        if(data.success)
          $("#board_copied_lightbox").foundation('reveal', 'open')
      ,
      'json'
    )

  $("#close_board_copied_lightbox").click ->
    $("#board_copied_lightbox").foundation('reveal', 'close')