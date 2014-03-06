$(document).ready ->
  $('#invite_users_page_1').find('#add_another_user_invite').on('click', (event) ->
    add_fields = $('.invite-user:first').clone(true)
    add_fields.find('input').val('')
    add_fields.find('input').removeClass('error').removeClass('invalid').removeClass('valid')
    $('#invite_users_page_1').find('#invite_user_fields').append(add_fields)
    removeInviteUsersErrorMessage(add_fields)
    false
  )
  
  $('#share_tiles_email_preview').on('load', (event) ->
    if document.getElementById
      newheight = document.getElementById('share_tiles_email_preview').contentWindow.document.body.scrollHeight
      newwidth = document.getElementById('share_tiles_email_preview').contentWindow.document.body.scrollWidth

      document.getElementById('share_tiles_email_preview').height = (newheight) + "px"
      document.getElementById('share_tiles_email_preview').width = (newwidth) + "px"
      $('#share_tiles_email_preview_blocker').height(newheight + "px")
      $('#share_tiles_email_preview_blocker').width(newwidth + "px")
    return
  )
  removeInviteUsersErrorMessage = (container) ->
    container.find('.alert-box').remove()
  
  showInviteUsersErrorMessage = (error_message, container) ->
    div_error = '<div data-alert class="alert-box error" style="display:none;">' + error_message + '<a href="#" class="close">&times;</a></div>'
    container.prepend(div_error)
    container.find('.alert-box').show('fast')
    
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
      showInviteUsersErrorMessage("Please specify at least one invite", $("#invite_users_modal"))
    else
      removeInviteUsersErrorMessage($('#share_tiles_digest>').find("#invite_users_modal"))
    has_one_entry && all_ok
  #submit form
  $('#submit_invite_users').on('click', (event) ->
    event.preventDefault()
    #$(this).attr("href")
    if validateInvitedUsers()
      History.pushState {state: 2}, "Airbo", "?state=2"
      loadPage2()
    else
      loadPage1()
    false
  )
  $('#invite_users_page_1').find('#skip_invite_users').on('click', (event) ->
    event.preventDefault()
    #$(this).attr("href")
    History.pushState {state: 4}, "Airbo", "?state=4"
    loadPage4()
    false
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
    $('#activate_tiles_digest').find('.activated_button').hide()
    
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
    
    #ignore_page_1_2 = true #don't allow user to see page 1 and 2 anymore
    History.pushState {state: 3}, "Airbo", "?state=success"
    loadPage3()
  ).bind "ajax:error", (e, xhr, status, error) ->    
    errors = $.parseJSON(xhr.responseText).errors
    for key,value of errors      
      showInviteUsersErrorMessage("#{key} - #{value}", $('#share_tiles_digest>').find("#invite_users_modal"))
      
  $('#invite_users_page_1').find('.history_back.page_1').on('click', (event) ->
    loadPage0()
    History.back()
  )
  $('#invite_users_page_2').find('.history_back.page_2').on('click', (event) ->
    loadPage1()
    History.back()
  )
  $('#invite_users_page_2').find('#invite_users_send_button').on('click', (event) ->    
    if validateInvitedUsers()      
      $('#share_tiles_digest').find('#invite_users_form').submit()
    false
    )
  
  old_message_size = 0
  $('#invite_users_page_2').find('#users_invite_message').on('keyup', (event) ->
    if $(this).val().length < old_message_size
      $('#invite_users_page_2').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val())
      
    old_message_size = $(this).val().length
    
  ).on('keypress', (event) ->
    $('#invite_users_page_2').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val())
  )  
    
  $('#share_tiles_digest').find("#invite_users_form").validate
    rules:
      'users_invite[users][][name]':
        minlength: 2
        required: true

      'users_invite[users][][email]':
        required: true
        email: true
    onkeyup: false
    highlight: (element, errorClass, validClass) ->
      if element.value.length > 0       
        $(element).removeAttr('style').addClass('error').removeClass('valid')#.addClass('invalid')
      else
        $(element).removeAttr('style').removeClass('error').removeClass('valid')#.addClass('invalid')
        
      return
    unhighlight: (element, errorClass, validClass) ->
      #now check if email is already present if checking email
      if $(element).hasClass('email') && element.value.length > 2
        #add spinner where checkmark appears        
        $(element).removeAttr('style').removeClass('invalid').removeClass('valid').removeClass('error').addClass('waiting')
        $.ajax(
          url: '/client_admin/validate_email', 
          data:
            email: element.value
          success: (error_message) ->
            if error_message.match(/\S+/)
              #got error message
              removeInviteUsersErrorMessage($(element).closest('li'))
              showInviteUsersErrorMessage(error_message, $(element).closest('li'))
              $(element).parent().get(0)['id']
              $(element).removeAttr('style').addClass('error').removeClass('valid')#.addClass('invalid')
            else
              removeInviteUsersErrorMessage($(element).closest('li'))
              $(element).removeAttr('style').removeClass('invalid').removeClass('error').addClass('valid')
          complete: () ->
            #hide spinner created            
            $(element).removeClass('waiting')

          #async: false
        )
      #only add valid class if there is some data inserted
      else if element.value.length > 0
        $(element).removeAttr('style').removeClass('invalid').removeClass('error').addClass('valid')
      else
        $(element).removeAttr('style').removeClass('invalid').removeClass('error')
        
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
        $('#success_share_url').find('#share_active_tile').html(data)
    true
   
  loadPage3 = () ->
    hideAll()
    $('#success_share_url').show()    
    $('#success_share_digest').show()
    $.get '/client_admin/show_first_active_tile', (data) ->
        $('#success_share_url').find('#share_active_tile').html(data)
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