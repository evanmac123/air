window.tilePublicPage = ->
  $("#save_progress_button").text("Create Board")
  $("#save_progress_button").click ->
    $('#sign_up_modal').foundation('reveal', 'open')
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
    tile_id = $("[data-current-tile-id]").data("current-tile-id")
    $.post('/ping', {event: "Tile - Viewed", properties: {action: action, tile_id: tile_id} })
    true
  #
  # =>  Sign up form
  #
  $().ready ->
    $('#create_account_form').on('submit',
      creationStartCallback).on('ajax:success', creationResponseCallback)

  creationStartCallback = (event) ->
    $("#submit_account_form").attr("disabled", "disabled")
    $('#create_account_form').find(".errors_field").text("")

  creationResponseCallback = (event, data) ->
    if data.status == 'success'
      window.location.href = "/client_admin/tiles"
    else
      $('#create_account_form').find(".errors_field").text(data.errors)
      $("#submit_account_form").removeAttr("disabled")
