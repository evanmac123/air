var defaultCustomHeadline, defaultCustomSubject, emailPreviewLink, loadEmailPreview, previewIsFollowUp, resizeEmailPreview, textForSubject, updateCustomHeadline;

emailPreviewLink = function(followUp) {
  if (followUp == null) {
    followUp = false;
  }
  return "/client_admin/preview_invite_email?follow_up_email=" + followUp + "&&custom_message=%20";
};

loadEmailPreview = function(followUp) {
  if (followUp == null) {
    followUp = false;
  }
  return $('#digest_management').find('#share_tiles_email_preview').attr('src', emailPreviewLink(followUp));
};

previewIsFollowUp = function() {
  return $("#show_follow_up_preview").hasClass("selected");
};

defaultCustomSubject = function() {
  if (previewIsFollowUp()) {
    return "Don't Miss Your New Tiles";
  } else {
    return "New Tiles";
  }
};

textForSubject = function(text) {
  if (text === '') {
    return defaultCustomSubject();
  } else if (previewIsFollowUp()) {
    return "Don't Miss: " + text;
  } else {
    return text;
  }
};

defaultCustomHeadline = function() {
  if (previewIsFollowUp()) {
    return "Don't miss your new tiles";
  } else {
    return 'Your New Tiles Are Here!';
  }
};

updateCustomHeadline = function(event) {
  var value;
  value = $(this).val();
  if (value === '') {
    value = defaultCustomHeadline();
  }
  return $('#digest_management #share_tiles_email_preview').contents().find('#custom_headline').html(value);
};

resizeEmailPreview = function() {
  var maxHeight, newHeight, newTotalHeight, newWidth;
  newHeight = document.getElementById('share_tiles_email_preview').contentWindow.document.body.scrollHeight;
  maxHeight = $('#digest_management').find('.notification_controls').height();
  newWidth = document.getElementById('share_tiles_email_preview').contentWindow.document.body.scrollWidth;
  $('#share_tiles_email_preview').height(newHeight + "px");
  $('#share_tiles_email_preview').width(newWidth + "px");
  newTotalHeight = $('.large-9.email_preview').height();
  if (newTotalHeight > maxHeight) {
    newHeight -= newTotalHeight - maxHeight;
    $('#share_tiles_email_preview').height(newHeight + "px");
  }
  return window.resizedEmailPreview = true;
};

window.digestManagement = function() {
  $(document).ready(function() {
    $('.client_admin-shares-show').foundation();
    return loadEmailPreview();
  });
  $(".email_preview_switchers a").click(function(e) {
    e.preventDefault();
    $(".email_preview_overlay").fadeIn();
    $(".email_preview_switchers a").removeClass("selected");
    $(this).addClass("selected");
    return loadEmailPreview($(this).attr('id') === "show_follow_up_preview");
  });
  $('#share_tiles_email_preview').on('load', function(event) {
    if (!window.resizedEmailPreview) {
      resizeEmailPreview();
    }
    $(".email_preview_overlay").fadeOut();
    return $("#digest_custom_message, #digest_custom_subject, #digest_custom_headline").trigger('keyup');
  });
  $('#digest_management').find('#digest_custom_message').on('keyup', function(event) {
    return $('#digest_management').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val());
  }).on('keypress', function(event) {
    return $('#digest_management').find('#share_tiles_email_preview').contents().find('#custom_message').html($(this).val());
  });
  $('#digest_management #digest_custom_headline').on('keyup', updateCustomHeadline).on('keypress', updateCustomHeadline);
  $('#digest_custom_subject').keyup(function(event) {
    var text;
    text = $(event.target).val();
    return $('.subject-field').text(textForSubject(text));
  });
  return $("#send_test_digest").click(function(e) {
    e.preventDefault();
    $("#digest_type").val("test_digest");
    return $("#tiles_digest_form").submit();
  });
};
