window.tilePublicPage = ->
  $("#save_progress_button").text("Create Board")
  $("#save_progress_button").click ->
    $("#modal_link").click()
    pingOnAction "Clicked Create Board"

  $(".close_sign_up_modal").click ->
    $('#sign_up_modal').foundation('reveal', 'close')

  $(".tile_multiple_choice_answer a").click ->
    pingOnAction "Answered Question"

  $("#sign_in_button").click ->
    pingOnAction "Clicked Sign-in"

  $(".go_home").click ->
    pingOnAction "Clicked Logo"

  pingOnAction = (action) ->
    $.post('/ping', {event: "Tile - Viewed", action: action})
    true