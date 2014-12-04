hideSpinner = () -> $('.public_board_controls #spinner').hide()
showSpinner = () -> $('.public_board_controls #spinner').show()

updatePublicBoardControls = (event, data) ->
  hideSpinner()
  event.preventDefault()
  $('.public_board_controls').replaceWith(data)

switchPublicStatusIfEngaged = (event) ->
  if $(event.target).hasClass 'engaged'
    event.preventDefault()
  else
    showSpinner()

$(document).on('click', '#on_toggle, #off_toggle', switchPublicStatusIfEngaged)
$(document).on('ajax:success', '#on_toggle, #off_toggle', updatePublicBoardControls)

$(document).on('keydown keyup keypress', '#public_board_field', (event) ->
  if(!(event.ctrlKey || event.altKey || event.metaKey))
    event.preventDefault()
)

$(document).on('click', '#public_board_field', (event) ->
  event.preventDefault()
  $(event.target).focus().select()
)

$(document).ready ->
  $('#digest_management').find('#share_tiles_email_preview').attr('src', '/client_admin/preview_invite_email?custom_message=%20')
  $('#activated_users').hide()
  $('#digest_send_to').on('change', (event) ->
    if $('#digest_send_to option:selected').text() == "All Users"
      $('#all_users').show()
      $('#activated_users').hide()
    else if $('#digest_send_to option:selected').text() == "Activated Users"
      $('#all_users').hide()
      $('#activated_users').show()
  )

  $('.status_div').find('.private').on 'click', (event) ->
    $('.status_div').find('.switch > #private_button').click()
    
  $('.status_div').find('.public').on 'click', (event) ->
    $('.status_div').find('.switch > #public_button').click()
    
  
  $('.status_div').find('.switch').on 'click', (event) ->
    if $("#private_button").attr("checked")
      demo_id = $('.new_public_board').attr('id')
      $.ajax({
        url : ("/client_admin/public_boards/"+demo_id),
        type : 'DELETE',       
      })
      $('.status_div').find('.private').addClass('engaged').removeClass('disengaged')
      $('.status_div').find('.public').addClass('disengaged').removeClass('engaged')
      $('.status_message_div').html("<div class='private-demo-message'>SHARE LINK IS LOCKED</div>")
      document.getElementById("public_board_field").setAttribute("disabled","true")
    else
      $.post("/client_admin/public_boards")
      $('.status_div').find('.private').addClass('disengaged').removeClass('engaged')
      $('.status_div').find('.public').addClass('engaged').removeClass('disengaged')
      $('.status_message_div').html("<div class='public-demo-message'>SHARE LINK IS ACTIVE</div>")
      document.getElementById("public_board_field").removeAttribute("disabled")

    return
    
  return
