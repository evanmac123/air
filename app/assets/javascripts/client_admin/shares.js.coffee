$(document).ready ->
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
  has_one_entry = false
  ignore_pop_calls = false
  validateInvitedUsers = () ->
    all_ok = true
    user_invites = $('.invite-user')
    has_one_entry = false
    for user_invite in user_invites
      name_input = $(user_invite).find('input.name')
      email_input = $(user_invite).find('input.email')
      if email_input.val()
        console.log("email doesn't match: "+email_input.val());
        unless email_input.val().match(/^((?!\.)[a-z0-9._%+-]*(?!\.)\w)@[a-z0-9-\.]+\.[a-z.]{2,5}(?!\.)\w$/i)
          $(email_input).addClass('error').addClass('invalid')
          console.log("email doesn't match: "+email_input.val());
          all_ok = false
        else
          $(email_input).removeClass('error').removeClass('invalid')
        
        unless name_input.val()
          $(name_input).addClass('error').addClass('invalid')         
          #Sorry, you can't add this user because they already have an account. A user can only belong to one board.
          all_ok = false
        else
          $(name_input).removeClass('error').removeClass('invalid')        
          has_one_entry = true
      else
        #no email
        if name_input.val()
          $(email_input).addClass('error').addClass('invalid') 
          console.log("name doesn't match: "+email_input.val());
          all_ok = false
        else
          $(email_input).removeClass('error').removeClass('invalid')
          $(name_input).removeClass('error').removeClass('invalid')
          
    #No need for personal message to be validated
    unless has_one_entry
      console.log("No entry found");
      $("#invite_users_modal_errors").addClass('error').addClass('invalid')
      $("#invite_users_modal_errors").html("Please specify at least one invite")
#      $(".share_url").toggle()
#      $(".invite_user_div").toggle()
    else
      $("#invite_users_modal_errors").removeClass('error').removeClass('invalid')
      $("#invite_users_modal_errors").html('')
    has_one_entry && all_ok  
  #submit form
  $('#submit_invite_users').on('click', (event) ->
    event.preventDefault()
    #$(this).attr("href")
    console.log('submit invite users called')
    if validateInvitedUsers()
      console.log('validation successful')
      console.log('validation submit invite users called')
      History.pushState {state: 2}, "State 2", "?state=2"
      loadPage2()
    false
  )
        
  $("#invite_users_modal").on("ajax:success", (e, data, status, xhr) ->
    $('#invite_users_modal #spinner_large').hide()
    History.pushState {state: 3}, "State 3", "?state=3"
    loadPage3()
  ).bind "ajax:error", (e, xhr, status, error) ->
    $('#invite_users_modal #spinner_large').hide()
    $("#invite_users_modal_errors").addClass('error')
    errors = $.parseJSON(xhr.responseText).errors
    for key,value of errors      
      $("#invite_users_modal_errors").html("#{key} - #{value}")
    
  $('#help_bubble').on('click', (event) ->
      $('.speech').toggle()
    )

 
  $('#send_button').on('click', (event) ->
    if validateInvitedUsers()
      $('#invite_users_modal #spinner_large').show()
      $('#invite_users_form').submit()
    else
      unless has_one_entry
        #take user to share 
        History.pushState {state: 4}, "State 4", "?state=4"
        loadPage4()
    false
    )
    
  $('#next_button').on('click', (event) ->    
    if validateInvitedUsers()
      $('#invite_users_modal #spinner_large').show()
      $('#invite_users_form').submit()
    else
      History.pushState {state: 4}, "State 4", "?state=4"
      loadPage4()
    false
    )

  $("#invite_users_form").validate
    rules:
      name:
        minlength: 2
        required: true

      email:
        required: true
        email: true

    highlight: (element, errorClass, validClass) ->
      $(element).removeAttr('style').addClass('error').removeClass('valid')#.addClass('invalid')
      return

    unhighlight: (element, errorClass, validClass) ->
      $(element).removeAttr('style').removeClass('invalid').removeClass('error').addClass('valid')
      return
    
    errorPlacement: (error, errorElement) ->
      return

  hideAll = () ->
    $(".share_url").hide()
    $(".invite_user_div").hide()    

    $('#digest').hide()
    $('.share_url').hide()
    $('#success_section').hide()
    $('#invite_users_form').hide()

    $('#invite_users').hide()
    $('#user_invite_message').hide()
    $('#form_buttons').hide()
    $('#message_buttons').hide()
    $('#form_links').hide()
    $('#add_people_header').hide()


  loadPage4 = () ->
    hideAll()
    
    $('#digest').show()
    $(".share_url").show()
    true
   
  loadPage3 = () ->
    hideAll()
    ignore_pop_calls = true
    
    $('.share_url').show()
    $('#success_section').show()
    $('#invite_users_form').submit()
    true
  
  loadPage2 = () ->
    hideAll()
    $(".invite_user_div").show()
    $("#invite_users_form").show()
    $('#digest').show()

    $('#share_tiles_header').html('Add a personal message and send!')
    $('#user_invite_message').show()
    $('#message_buttons').show()
    true
  
  loadPage1 = () ->
    hideAll()
    $('#invite_users_form').show()
    $('#digest').show()

    $(".invite_user_div").show()
    $('#invite_users').show()
    $('#share_tiles_header').html('Add a personal message and send!')
    $('#form_buttons').show()
    $('#form_links').show()
    $('#add_people_header').show()
    true
    
#  $(window).on("popstate", (e) ->
  History.Adapter.bind(window,'statechange', () ->
    unless ignore_pop_calls
      state = History.getState();
      switch state.data.state
        when 1
          loadPage1()
        when 2
          loadPage2()
        when 3
          loadPage3()
        when 4
          loadPage4()
        else
          loadPage1()
  )