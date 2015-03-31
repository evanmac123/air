emailPreviewLink = (followUp = false) ->
  "/client_admin/preview_invite_email?follow_up_email=#{followUp}&&custom_message=%20"

loadEmailPreview = (followUp = false) ->
  $('#digest_management')
    .find('#share_tiles_email_preview')
    .attr('src', emailPreviewLink(followUp))

previewIsFollowUp = ->
  $("#show_follow_up_preview").hasClass "selected"

defaultCustomSubject = ->
  if previewIsFollowUp()
    "Don't Miss Your New Tiles"
  else
    "New Tiles"

textForSubject = (text) ->
  if(text == '') 
    defaultCustomSubject()
  else if previewIsFollowUp()
    "Don't Miss: " + text 
  else
    text

defaultCustomHeadline = ->
  if previewIsFollowUp()
    "Don't miss your new tiles"
  else
    'Your New Tiles Are Here!'

$(document).ready ->
  $('.client_admin-shares-show').foundation()
  loadEmailPreview()

  $(".email_preview_switchers a").click (e) ->
    e.preventDefault()
    $(".email_preview_switchers a").removeClass "selected"
    $(@).addClass "selected"
    loadEmailPreview $(@).attr('id') == "show_follow_up_preview"
  
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
    $("#digest_custom_message, #digest_custom_subject, #digest_custom_headline").trigger('keyup') 
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
  

  $('#digest_management').find('#digest_custom_message').on('keyup', (event) ->
    $('#digest_management').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val())
  ).on('keypress', (event) ->
    $('#digest_management').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val())
  )

  updateCustomHeadline = (event) ->
    value = $(this).val()
    if value == ''
      value = defaultCustomHeadline()
    $('#digest_management #share_tiles_email_preview').contents().find('#custom_headline').html(value)

  $('#digest_management #digest_custom_headline').on('keyup', updateCustomHeadline).on('keypress', updateCustomHeadline)

  $('#invite_users_page_1').find('input').select((event) ->
    $(this).removeAttr('style').removeClass('invalid').removeClass('valid').removeClass('error')    
  )

  $('#digest_custom_subject').keyup (event) ->
    text = $(event.target).val()
    $('.subject-field').text textForSubject(text)

  $("#send_test_digest").click (e) ->
    e.preventDefault()
    $("#digest_type").val("test_digest")
    $("#tiles_digest_form").submit()
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
  
  hideAll = () ->
    $('#activate_tiles_digest').hide()
    
    $(".invite_users_header_page_1").hide()
    $('#invite_users_page_1').hide()

    $('#success_share_url').hide()
    $('#success_share_digest').hide()

    $('#invite_users_page_2').hide()
    $(".invite_users_header_page_2").hide()
    $('#invite_users_modal').hide()
