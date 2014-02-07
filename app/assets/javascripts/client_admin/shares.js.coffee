$(document).ready ->

  invite_users_modal = $('#invite_users_modal[auto_show]')
  if invite_users_modal? and invite_users_modal.length > 0
    invite_users_modal.lightbox_me()
    
  create_tile_modal = $('#create_tile_modal')
  if create_tile_modal? and create_tile_modal.length > 0
    create_tile_modal.lightbox_me()
    
  $('#show_invite_users_modal').on('click', (event) ->
    $('#invite_users_modal').lightbox_me()
  )
  $('#add_another_user_invite').on('click', (event) ->
    add_fields = $('.invite-user:first').clone(true)
    add_fields.find('input').val('')
    $("#invite_users").append(add_fields)
    add_fields.find('input:first').focus()
  )
  
  # Dismiss
  $('#dismiss_invite_users').on('click', (event) ->
    $('#invite_users_modal').trigger('close')
    $.post( "/client_admin/users_invites/dismissed", (data) ->
      #console.log "post successful"
      #nothing to do here
    );
  )
  $('#dismiss_create_tile_modal').on('click', (event) ->
    $('#create_tile_modal').trigger('close')
  )
  
  #validate invited users
  validateInvitedUsers = () ->
    all_ok = true
    user_invites = $('.invite-user')
    has_one_entry = false
    for user_invite in user_invites
      name_input = $(user_invite).find('input.name')
      email_input = $(user_invite).find('input.email')
      if email_input.val()
        unless email_input.val().match(/^((?!\.)[a-z0-9._%+-]+(?!\.)\w)@[a-z0-9-\.]+\.[a-z.]{2,5}(?!\.)\w$/i)
          $(email_input).addClass('error')
          all_ok = false
        else
          $(email_input).removeClass('error')
        
        unless name_input.val()
          $(name_input).addClass('error')
          all_ok = false
        else
          $(name_input).removeClass('error')        
          has_one_entry = true
      else
        #no email
        if name_input.val()
          $(email_input).addClass('error')
          all_ok = false
        else
          $(email_input).removeClass('error')
          $(name_input).removeClass('error')
          
    #No need for personal message to be validated
    unless has_one_entry
      $("#invite_users_modal_errors").addClass('error')
      $("#invite_users_modal_errors").html("Please specify at least one invite")
    else
      $("#invite_users_modal_errors").removeClass('error')      
      $("#invite_users_modal_errors").html('')
    has_one_entry && all_ok  
  #submit form
  $('#submit_invite_users').on('click', (event) ->
    event.preventDefault()
    if validateInvitedUsers()
      $('#invite_users_form').submit()
  )
  
  $("#invite_users_modal").on("ajax:success", (e, data, status, xhr) ->
    $('#invite_users_modal').trigger('close')
  ).bind "ajax:error", (e, xhr, status, error) ->
    $("#invite_users_modal_errors").addClass('error')
    errors = $.parseJSON(xhr.responseText).errors
    for key,value of errors      
      $("#invite_users_modal_errors").html("#{key} - #{value}")
    
