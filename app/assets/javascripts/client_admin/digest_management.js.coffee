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

updateCustomHeadline = (event) ->
  value = $(this).val()
  if value == ''
    value = defaultCustomHeadline()
  $('#digest_management #share_tiles_email_preview').contents().find('#custom_headline').html(value)

resizeEmailPreview = ->
  newHeight = document.getElementById('share_tiles_email_preview')
                      .contentWindow.document.body.scrollHeight
  maxHeight = $('#digest_management').find('.notification_controls').height()
  newWidth =  document.getElementById('share_tiles_email_preview')
                      .contentWindow.document.body.scrollWidth

  $('#share_tiles_email_preview').height(newHeight + "px")
  $('#share_tiles_email_preview').width(newWidth + "px")
  
  newTotalHeight = $('.large-9.email_preview').height()
  if newTotalHeight > maxHeight
    #re-adjust iframe
    newHeight -= (newTotalHeight - maxHeight) 
    $('#share_tiles_email_preview').height(newHeight + "px")
  window.resizedEmailPreview = true

window.digestManagement = ->
  $(document).ready ->
    $('.client_admin-shares-show').foundation()
    loadEmailPreview()

  $(".email_preview_switchers a").click (e) ->
    e.preventDefault()
    $(".email_preview_overlay").fadeIn()
    $(".email_preview_switchers a").removeClass "selected"
    $(@).addClass "selected"
    loadEmailPreview $(@).attr('id') == "show_follow_up_preview"
  
  $('#share_tiles_email_preview').on 'load', (event) ->
    resizeEmailPreview() unless window.resizedEmailPreview
    $(".email_preview_overlay").fadeOut()
    $("#digest_custom_message, #digest_custom_subject, #digest_custom_headline")
      .trigger('keyup')

  $('#digest_management').find('#digest_custom_message')
    .on('keyup', (event) ->
      $('#digest_management')
        .find('#share_tiles_email_preview')
        .contents()
        .find('#custom_message')
        .html($(this).val())
    ).on('keypress', (event) ->
      $('#digest_management')
        .find('#share_tiles_email_preview')
        .contents()
        .find('#custom_message')
        .html($(this).val())
    )

  $('#digest_management #digest_custom_headline')
    .on('keyup', updateCustomHeadline)
    .on('keypress', updateCustomHeadline)

  $('#digest_custom_subject').keyup (event) ->
    text = $(event.target).val()
    $('.subject-field').text textForSubject(text)

  $("#send_test_digest").click (e) ->
    e.preventDefault()
    $("#digest_type").val("test_digest")
    $("#tiles_digest_form").submit()
