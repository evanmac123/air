$(document).ready ->
  $('.client_admin-shares-show').foundation()
  
  $('#invite_users_page_1').find('#add_another_user_invite').on('click', (event) ->
    add_fields = $('.invite-user:first').clone(true)
    add_fields.find('input').val('')
    add_fields.find('input').removeClass('error').removeClass('invalid').removeClass('valid')
    $('#invite_users_page_1').find('#invite_user_fields').append(add_fields)
    removeInviteUsersErrorMessage(add_fields, 'main')
    false
  )
  
  $('#invite_users_page_2').find('#share_tiles_email_preview').on('load', (event) ->
    if document.getElementById
      newHeight = document.getElementById('share_tiles_email_preview').contentWindow.document.body.scrollHeight - 250
      newHeight = 520 if newHeight > 520
      newWidth = document.getElementById('share_tiles_email_preview').contentWindow.document.body.scrollWidth

      document.getElementById('share_tiles_email_preview').height = (newHeight) + "px"
      document.getElementById('share_tiles_email_preview').width = (newWidth) + "px"
      $('#share_tiles_email_preview_blocker').height('100%')
      $('#share_tiles_email_preview_blocker').width('70%')
      custom_message = $('#invite_users_page_2').find('#users_invite_message')
      $('#invite_users_page_2').find('#share_tiles_email_preview').contents().find('#custom_message').html($(custom_message).val())
    return
  )

  $('#share_tiles_email_preview').on('load', (event) ->
    if document.getElementById
      newHeight = document.getElementById('share_tiles_email_preview').contentWindow.document.body.scrollHeight
      maxHeight = $('#digest_management').find('.notification_controls').height()
      
      newWidth = document.getElementById('share_tiles_email_preview').contentWindow.document.body.scrollWidth

      $('#share_tiles_email_preview').height(newHeight + "px")
      $('#share_tiles_email_preview').width(newWidth + "px")
      
      newTotalHeight = $('.large-9.email_preview').height()
      if newTotalHeight > maxHeight
        #re-adjust iframe
        newHeight -= (newTotalHeight - maxHeight) 
        $('#share_tiles_email_preview').height(newHeight + "px")
        
      custom_message = $('#invite_users_page_2').find('#users_invite_message')
      
      $('#invite_users_page_2').find('#share_tiles_email_preview').contents().find('#custom_message').html($(custom_message).val())
    return
  )

  removeInviteUsersErrorMessage = (container, type) ->
    container.find('.error_message>.' + type).html('')
      
  showInviteUsersErrorMessage = (error_message, container, type) ->
    #div_error = '<div class="'+ type + '">' + error_message + '</div>'
    container.find('.error_message>.' + type).html(error_message)#prepend(div_error)
    $('#submit_invite_users').addClass('disengaged').removeClass('engaged')
    $.ajax("/client_admin/share/got_error?error_message=#{error_message}")
    
  #validate invited users
  num_valid_users = 0
  validateInvitedUsers = (is_show_error) ->
    all_ok = true
    user_invites = $('.invite-user')
    num_valid_users = 0
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
            num_valid_users += 1
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
    if is_show_error
      if num_valid_users < 1
          showInviteUsersErrorMessage("Please specify at least one user", $('#share_tiles_digest').find("#invite_users_modal"), 'main')        
      else
          removeInviteUsersErrorMessage($('#share_tiles_digest').find("#invite_users_modal"), 'main')
    (num_valid_users > 0) && all_ok
  #submit form
  $('#invite_users_page_1').find('#submit_invite_users').on('click', (event) ->
    event.preventDefault()   
    if validateInvitedUsers(true)
      $.ajax("/client_admin/share/successfully_added_users") 
      History.pushState {state: 2}, "Airbo", "?state=2"
      loadPage2()
    else
      loadPage1()
    $.ajax('/client_admin/share/number_of_valid_users_added?num_valid_users='+num_valid_users)
    false
  )
  $('#invite_users_page_1').find('#skip_invite_users').on('click', (event) ->
    $.ajax("/client_admin/share/clicked_skip")
    event.preventDefault()
    History.pushState {state: 4}, "Airbo", "?state=4"
    loadPage4()
    false
  )
  $('#invite_users_page_1').find('#mail_to_link').on('click', (event) ->
    $.ajax("/client_admin/share/clicked_mail_to")
  )
  $('#success_share_digest').find('#share_mail').on('click', (event) ->
    $.ajax("/client_admin/share/clicked_success_mail")
  )
  $('#success_share_digest').find('#share_twitter').on('click', (event) ->
    $.ajax("/client_admin/share/clicked_success_twitter")
  )
  $('#success_share_digest').find('#public_board_field').one('select', (event) ->
    $.ajax("/client_admin/share/selected_public_board?path=success_share_digest")
  )
  
  $('#success_share_url').find('#share_mail').on('click', (event) ->
    $.ajax("/client_admin/share/clicked_share_mail")
  )
  $('#success_share_url').find('#share_twitter').on('click', (event) ->
    $.ajax("/client_admin/share/clicked_share_twitter")
  )
  $('#success_share_url').find('#public_board_field').one('select', (event) ->
    $.ajax("/client_admin/share/selected_public_board?path=success_share_url")
  )

  deactivatedTiles = () ->
    $('.tile_buttons>.archive_button').filter( () -> 
      $(this).css('display') == 'none'
      )
  
  activatedTiles = () ->
    $('.tile_buttons>.activate_button').filter( () -> 
      $(this).css('display') == 'none'
      )      

  revealActivatedTilesSuccess = () ->
    $('#activate_tiles_digest').find("#success_activated_tiles").foundation "reveal", "open"
    setTimeout (->
      $('#activate_tiles_digest').find("#success_activated_tiles").foundation "reveal", "close"
    ), 5000
  
  $('#activate_tiles_digest').find('.tile_buttons>.archive_button').on("ajax:success",  (e, data, status, xhr) ->
    #DONE mark tile as checked
    $(this).closest('td>div.tile_thumbnail').find('.checked_activated_tile').remove()
    #DONE activate next buttons
    $(this).closest('.tile_buttons').find('.activate_button').show()
    $(this).hide()
    
    if activatedTiles().size() < 1      
      $('#activate_tiles_digest').find('#next_bottom_enabled').hide()
      $('#activate_tiles_digest').find('#next_top_enabled').hide()
      
      $('#activate_tiles_digest').find('#next_bottom_disabled').show()
      $('#activate_tiles_digest').find('#next_top_disabled').show()
  )
  
  $('#activate_tiles_digest').find('.tile_buttons>.activate_button').on("ajax:success",  (e, data, status, xhr) ->
    #DONE mark tile as checked
    #DONE activate next buttons
    $(this).closest('.tile_buttons').find('.archive_button').show()
    $(this).hide()
    if deactivatedTiles().size() > 0
      if $(this).closest('td>div.tile_thumbnail>i.checked_activated_tile').length < 1
        $(this).closest('td>div.tile_thumbnail').prepend("<i class='fa fa-check-circle fa-3x checked_activated_tile'></i>")

      $('#activate_tiles_digest').find('#next_bottom_disabled').hide()
      $('#activate_tiles_digest').find('#next_top_disabled').hide()
      
      $('#activate_tiles_digest').find('#next_bottom_enabled').show()
      $('#activate_tiles_digest').find('#next_top_enabled').show()
    else
      #mark the only tile available as checked
      revealActivatedTilesSuccess()
      
  ).bind "ajax:error", (e, xhr, status, error) ->
    console.log('Could not activate tile')

  $('#activate_tiles_digest').find('#activate_all_tiles').on("ajax:success",  (e, data, status, xhr) ->
    #make activated tiles all checked  
    $('#invite_users_page_1').find('.history_back.page_1').show()
    if $('#activate_tiles_digest').find('#share_archive>table>tbody>tr>td>div.tile_thumbnail>i.checked_activated_tile').length < 1
      $('#activate_tiles_digest').find('#share_archive>table>tbody>tr>td>div.tile_thumbnail'
      ).prepend("<i class='fa fa-check-circle fa-3x checked_activated_tile'></i>")
    $('#activate_tiles_digest').find('.archive_button').show()
    $('#activate_tiles_digest').find('.activate_button').hide()
    
    $(this).closest('td>div.tile_thumbnail>i.checked_activated_tile').remove()
    $(this).closest('td>div.tile_thumbnail').prepend("<i class='fa fa-check-circle fa-3x checked_activated_tile'></i>")
    revealActivatedTilesSuccess()
  ).bind "ajax:error", (e, xhr, status, error) ->
    console.log('Could not activate all tiles')

  $('#activate_tiles_digest').find("#activate_tiles_next_top").on("click", (e, data, status, xhr) ->
    $('#invite_users_page_1').find('.history_back.page_1').show()
    History.pushState {state: 1}, "Airbo", "?state=invite"
    loadPage1()
    )
    
  $('#activate_tiles_digest').find("#activate_tiles_next_bottom").on("click", (e, data, status, xhr) ->
    $('#invite_users_page_1').find('.history_back.page_1').show()
    History.pushState {state: 1}, "Airbo", "?state=invite"
    loadPage1()
    )
    
  $('#activate_tiles_digest').find("#success_activated_tiles").on('close',  (e, data, status, xhr) ->
    $('#invite_users_page_1').find('.history_back.page_1').show()
    History.pushState {state: 1}, "Airbo", "?state=invite"
    loadPage1()
    )
    
  $('#share_tiles_digest').find("#invite_users_modal").on("ajax:success", (e, data, status, xhr) ->
    
    History.pushState {state: 3}, "Airbo", "?state=success"
    loadPage3()
  ).bind "ajax:error", (e, xhr, status, error) ->    
    errors = $.parseJSON(xhr.responseText).errors
    for key,value of errors      
      showInviteUsersErrorMessage("#{key} - #{value}", $('#share_tiles_digest').find("#invite_users_modal"), 'main')
      
  $('#invite_users_page_2').find('.history_back.page_2').on('click', (event) ->
    $.ajax("/client_admin/share/clicked_add_more_users")
    loadPage1()
    History.back()
    false
  )
  $('#success_share_url').find('.history_back').on('click', (event) ->
    $.ajax("/client_admin/share/clicked_add_users")
    loadPage1()
    History.back()
    false
  )
  
  $('#invite_users_page_2').find('#invite_users_send_button').on('click', (event) ->    
    if validateInvitedUsers(true)      
      $('#share_tiles_digest').find('#invite_users_form').submit()
      $.ajax("/client_admin/share/successfully_sent")
    false
    )
  
  old_message_size = 0
  $('#invite_users_page_2').find('#users_invite_message').on('keyup', (event) ->
    if $(this).val().length < old_message_size
      $('#invite_users_page_2').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val())
      
    old_message_size = $(this).val().length
    
  ).on('keypress', (event) ->
    $('#invite_users_page_2').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val())
    $.ajax("/client_admin/share/changed_message")
  )

  $('#digest_management').find('#digest_custom_message').on('keyup', (event) ->
    $('#digest_management').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val())
  ).on('keypress', (event) ->
    $('#digest_management').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val())
  )

  updateCustomHeadline = (event) ->
    value = $(this).val()
    if value == ''
      value = "Your New Tiles Are Here!"
    $('#digest_management #share_tiles_email_preview').contents().find('#custom_headline').html(value)

  $('#digest_management #digest_custom_headline').on('keyup', updateCustomHeadline).on('keypress', updateCustomHeadline)

  $('#invite_users_page_1').find('input').select((event) ->
    $(this).removeAttr('style').removeClass('invalid').removeClass('valid').removeClass('error')    
  )
  
############JQuery Validation#################
  $.validator.addMethod("first_last_name", 
    (value, element) ->      
      return this.optional(element) || /\w+\s+\w+/.test(value)
    , 'Please enter first name and last name'
  )
  $.validator.addMethod("remote_validate_email", 
    (value, element) ->
      if this.optional(element) || element.value == ''
        return true
      else
        allOk = false
        $.ajax(
          url: '/client_admin/validate_email', 
          data:
            email: element.value
          success: (error_message) ->
            if error_message.match(/\S+/)
              showInviteUsersErrorMessage(error_message, $(element).closest('li'), 'email')
              allOk = false
            else
              allOk = true
            
          async: false
        )
        return allOk
    , ''
  )
  
  $('#share_tiles_digest').find("#invite_users_form").validate
    rules:
      'users_invite[users][][name]':
        minlength: 2
        first_last_name: true

      'users_invite[users][][email]':
        email: true
        remote_validate_email: true
    onkeyup: false
    highlight: (element, errorClass, validClass) ->
      if element.value.length > 0       
        $(element).removeAttr('style').addClass('error').removeClass('valid')#.addClass('invalid')
      else
        $(element).removeAttr('style').removeClass('error').removeClass('valid')#.addClass('invalid')
        
      return
    unhighlight: (element, errorClass, validClass) ->
      #now check if email is already present if checking email
      if $(element).hasClass('email')
        type = 'email'
      else
        type = 'name'
      removeInviteUsersErrorMessage($(element).closest('li'), type)
      $(element).removeAttr('style').removeClass('invalid').removeClass('valid').removeClass('error')
      if element.value.length > 0
        #only add valid class if there is some data inserted
        $(element).addClass('valid')
        if validateInvitedUsers(false)
            $.ajax("/client_admin/share/added_valid_user")
            $('#submit_invite_users').removeClass('disengaged').addClass('engaged')
          
      return
    
    errorPlacement: (error, errorElement) ->
      if $(errorElement).hasClass('email')
        type = 'email'
      else
        type = 'name'
      removeInviteUsersErrorMessage($('#share_tiles_digest').find("#invite_users_modal"), 'main')
      if error.text() != ''
        showInviteUsersErrorMessage(error.text(), $(errorElement).closest('li'), type)
      return

  hideAll = () ->
    $('#activate_tiles_digest').hide()
    
    $(".invite_users_header_page_1").hide()
    $('#invite_users_page_1').hide()

    $('#success_share_url').hide()
    $('#success_share_digest').hide()

    $('#invite_users_page_2').hide()
    $(".invite_users_header_page_2").hide()
    $('#invite_users_modal').hide()


  loadPage4 = () ->
    hideAll()
    $('#success_share_url').show()
    $.get '/client_admin/share/show_first_active_tile', (data) ->
        $('#success_share_url').find('#share_active_tile').html(data)
        $('#success_share_url').find('.arrow_image_right').show()
    true
   
  loadPage3 = () ->
    hideAll()
    $('#success_share_digest').show()
    $.get '/client_admin/share/show_first_active_tile', (data) ->
        $('#success_share_url').find('#share_active_tile').html(data)
        $('#success_share_url').find('.arrow_image_right').show()
    true
  
  loadPage2 = () ->
    hideAll()
    $('#invite_users_page_2').find('#share_tiles_email_preview').attr('src', '/client_admin/preview_invite_email?is_invite_user=true');
    $('#share_tiles_digest').show()    
    $('.invite_users_header_page_2').show()
    $('#invite_users_modal').show()
    $('#invite_users_page_2').show()
    true
  
  loadPage1 = () ->
    hideAll()
    $('#share_tiles_digest').show()
    $(".invite_users_header_page_1").show()
    $('#invite_users_modal').show()
    $('#invite_users_page_1').show()
    true
        
#  $(window).on("popstate", (e) ->
  History.Adapter.bind(window,'statechange', () ->
    state = History.getState();
    switch state.data.state
      when 1
        loadPage1()
      when 2
        loadPage2()
      when 3
        loadPage3()
      else
        loadPage1()
  )
