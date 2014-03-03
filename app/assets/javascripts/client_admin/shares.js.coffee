$(document).ready ->
  $('#invite_users_page_1').find('#add_another_user_invite').on('click', (event) ->
    add_fields = $('.invite-user:first').clone(true)
    add_fields.find('input').val('')
    add_fields.find('input').removeClass('error').removeClass('invalid').removeClass('valid')
    $('#invite_users_page_1').find('#invite_user_fields').append(add_fields)
    add_fields.find('input:first').focus()
  )
    
  #validate invited users
  has_one_entry = false
  ignore_page_1_2 = false
  validateInvitedUsers = () ->
    all_ok = true
    user_invites = $('.invite-user')
    has_one_entry = false
    for user_invite in user_invites
      name_input = $(user_invite).find('input.name')
      email_input = $(user_invite).find('input.email')
      if $(email_input).hasClass('error')
        all_ok = false
      else
        if $(name_input).hasClass('error')
          all_ok = false
        else
          name_empty = !name_input.val().match(/\S+/)
          email_empty = !email_input.val().match(/\S+/)
          if !name_empty && !email_empty
            #both not empty
            has_one_entry = true
          else
            #unless both empty
            unless name_empty && email_empty
              #either email or name is missing
              if email_empty
                $(email_input).addClass('error').addClass('invalid') 
                all_ok = false
              else 
                $(name_input).addClass('error').addClass('invalid') 
                all_ok = false
          
    #No need for personal message to be validated
    unless has_one_entry
      $("#invite_users_errors").addClass('error').addClass('invalid')
      $("#invite_users_errors").html("Please specify at least one invite")
    else
      $("#invite_users_errors").removeClass('error').removeClass('invalid')
      $("#invite_users_errors").html('')
    has_one_entry && all_ok  
  #submit form
  $('#submit_invite_users').on('click', (event) ->
    event.preventDefault()
    #$(this).attr("href")
    if validateInvitedUsers()
      History.pushState {state: 2}, "State 2", "?state=2"
      loadPage2()
    else
      loadPage1()
    false
  )
  $('#invite_users_page_1').find('#skip_invite_users').on('click', (event) ->
    event.preventDefault()
    #$(this).attr("href")
    History.pushState {state: 4}, "State 4", "?state=4"
    loadPage4()
    false
  )
  revealActivatedTilesSuccess = () ->
    $('#activate_tiles_digest').find("#success_activated_tiles").foundation "reveal", "open"
    setTimeout (->
      $('#activate_tiles_digest').find("#success_activated_tiles").foundation "reveal", "close"
    ), 5000
  
  $('#activate_tiles_digest').find('.tile_buttons>.archive_button').on("ajax:success",  (e, data, status, xhr) ->
    #DONE mark tile as checked
    $(this).closest('td').find('#share_active_tile').remove()
    #DONE activate next buttons
    
    if $('#activate_tiles_digest').find('.tile_buttons>.activate_button:visible').size() < 2      
      $('#activate_tiles_digest').find('#next_bottom_disabled').show()
      $('#activate_tiles_digest').find('#next_top_disabled').show()
      
      $('#activate_tiles_digest').find('#next_bottom_enabled').hide()
      $('#activate_tiles_digest').find('#next_top_enabled').hide()

    $(this).closest('.tile_buttons').find('.activate_button').show()
    $(this).hide()

  )
  $('#activate_tiles_digest').find('.tile_buttons>.activate_button').on("ajax:success",  (e, data, status, xhr) ->
    #DONE mark tile as checked
    $(this).closest('td').append("<p id='share_active_tile' class='fa fa-check-circle fa-3x'></p>")
    #DONE activate next buttons
    $(this).closest('.tile_buttons').find('.archive_button').show()
    $(this).hide()
    if $('.tile_buttons>.activate_button').size() > 0      
      $('#activate_tiles_digest').find('#next_bottom_disabled').hide()
      $('#activate_tiles_digest').find('#next_top_disabled').hide()
      
      $('#activate_tiles_digest').find('#next_bottom_enabled').show()
      $('#activate_tiles_digest').find('#next_top_enabled').show()
    else
      #mark the only tile available as checked
      revealActivatedTilesSuccess()
      
  ).bind "ajax:error", (e, xhr, status, error) ->
    console.log('Could not activate tile')

  $('#activate_tiles_digest').find("#activate_tiles_next_top").on("click", (e, data, status, xhr) ->
    $('#invite_users_page_1').find('.history_back.page_1').show()
    History.pushState {state: 1}, "State 1", "?state=invite"
    loadPage1()
    )
  $('#activate_tiles_digest').find("#activate_tiles_next_bottom").on("click", (e, data, status, xhr) ->
    $('#invite_users_page_1').find('.history_back.page_1').show()
    History.pushState {state: 1}, "State 1", "?state=invite"
    loadPage1()
    )
    
  $('#activate_tiles_digest').find("#success_activated_tiles").on('close',  (e, data, status, xhr) ->
    $('#invite_users_page_1').find('.history_back.page_1').show()
    History.pushState {state: 1}, "State 1", "?state=invite"
    loadPage1()
    )
  
  $('#activate_tiles_digest').find('#activate_all_tiles').on("ajax:success",  (e, data, status, xhr) ->
    #make activated tiles all checked  
    $('#invite_users_page_1').find('.history_back.page_1').show()
    $('#activate_tiles_digest').find('#share_archive>table>tbody>tr>td').append("<p id='share_active_tile' class='fa fa-check-circle fa-3x'></p>")
    revealActivatedTilesSuccess()
  ).bind "ajax:error", (e, xhr, status, error) ->
    console.log('Could not activate all tiles')
  
  $('#share_tiles_digest').find("#invite_users_modal").on("ajax:success", (e, data, status, xhr) ->
    
    #ignore_page_1_2 = true #don't allow user to see page 1 and 2 anymore
    History.pushState {state: 3}, "State 3", "?state=success"
    loadPage3()
  ).bind "ajax:error", (e, xhr, status, error) ->    
    $('#share_tiles_digest').find("#invite_users_errors").addClass('error')
    errors = $.parseJSON(xhr.responseText).errors
    for key,value of errors      
      $('#share_tiles_digest').find("#invite_users_errors").html("#{key} - #{value}")
      
  $('#invite_users_page_1').find('.history_back').click((event) ->
    loadPage0()
    History.back()
  )
  $('#invite_users_page_2').find('#invite_users_send_button').on('click', (event) ->    
    if validateInvitedUsers()      
      $('#share_tiles_digest').find('#invite_users_form').submit()
    false
    )
  
  $('#share_tiles_digest').find("#invite_users_form").validate
    rules:
      name:
        minlength: 2
        required: true

      email:
        required: true
        email: true
    onkeyup: false
    highlight: (element, errorClass, validClass) ->
      $(element).removeAttr('style').addClass('error').removeClass('valid')#.addClass('invalid')
      return
    unhighlight: (element, errorClass, validClass) ->
      #now check if email is already present if checking email
      if $(element).hasClass('email')
        #add spinner where checkmark appears
        $(element).removeAttr('style').removeClass('invalid').removeClass('valid').removeClass('error').addClass('waiting')
        $.ajax(
          url: '/client_admin/validate_email', 
          data:
            email: element.value
          success: (error_message) ->
            if error_message.match(/\S+/)
              #got error message
              $('#share_tiles_digest').find("#invite_users_errors").addClass('error')
              $('#share_tiles_digest').find("#invite_users_errors").html(error_message)
              $(element).removeAttr('style').addClass('error').removeClass('valid')#.addClass('invalid')
            else
              $(element).removeAttr('style').removeClass('invalid').removeClass('error').addClass('valid')
              $('#share_tiles_digest').find("#invite_users_errors").removeClass('error')
              $('#share_tiles_digest').find("#invite_users_errors").html('')
          complete: () ->
            #hide spinner created            
            $(element).removeClass('waiting')

          #async: false
        )
      else
        $(element).removeAttr('style').removeClass('invalid').removeClass('error').addClass('valid')
        
      return
    
    errorPlacement: (error, errorElement) ->
      return

  hideAll = () ->
    $('#activate_tiles_digest').hide()
    
    $(".invite_users_header_page_1").hide()
    $('#invite_users_page_1').hide()

    $('#success_share_url').hide()
    $('#success_share_digest').hide()

    $('#invite_users_page_2').hide()
    $(".invite_users_header_page_2").hide()


  loadPage4 = () ->
    hideAll()
    $('#success_share_url').show()
    $.get '/client_admin/show_first_active_tile', (data) ->
        $('#share_archive_custom').html(data)
    true
   
  loadPage3 = () ->
    hideAll()
    $('#success_share_url').show()    
    $('#success_share_digest').show()
    $.get '/client_admin/show_first_active_tile', (data) ->
        $('#share_archive_custom').html(data)
    true
  
  loadPage2 = () ->
    hideAll()
    $('#invite_users_page_2').find('#share_tiles_email_preview').attr('src', '/client_admin/preview_invite_email');
    $('#share_tiles_digest').show()    
    $('.invite_users_header_page_2').show()
    $('#invite_users_page_2').show()
    true
  
  loadPage1 = () ->
    hideAll()
    $('#share_tiles_digest').show()
    $(".invite_users_header_page_1").show()
    $('#invite_users_page_1').show()
    true
    
  loadPage0 = () ->
    #ignore_page_1_2 = false
    hideAll()
    $('#activate_tiles_digest').show()
    true
    
#  $(window).on("popstate", (e) ->
  History.Adapter.bind(window,'statechange', () ->
    state = History.getState();
    switch state.data.state
      when 0
        loadPage0()
      when 1
        if ignore_page_1_2 then History.back() else loadPage1()
      when 2
        if ignore_page_1_2 then History.back() else loadPage2()
      when 3
        loadPage3()
      when 4
        loadPage4()
      else
        loadPage0()
  )