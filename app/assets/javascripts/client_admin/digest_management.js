var Aiebo = window.Airbo || {};

Airbo.TilesDigestManagement = (function() {
  function emailPreviewLink(previewType) {
    var contentPath;
    if (previewType === "follow_up_email") {
      contentPath = "/client_admin/preview_tiles_digest_email?follow_up_email=true&&custom_message=%20";
    } else if (previewType === "sms") {
      contentPath = "/client_admin/tiles_digest_preview/sms";
    } else {
      contentPath = "/client_admin/preview_tiles_digest_email?follow_up_email=false&&custom_message=%20";
    }

    return contentPath;
  }

  function loadDigestPreview(previewType) {
    $('#digest_management').find('#share_tiles_digest_preview').attr('src', emailPreviewLink(previewType));
  }

  function previewIsFollowUp() {
    return $("#show_follow_up_preview").hasClass("selected");
  }

  function defaultCustomSubject() {
    if (previewIsFollowUp()) {
      return "Don't Miss Your New Tiles";
    } else {
      return "New Tiles";
    }
  }

  function textForSubject(text) {
    if (text === '') {
      return defaultCustomSubject();
    } else if (previewIsFollowUp()) {
      return "Don't Miss: " + text;
    } else {
      return text;
    }
  }

  function defaultCustomHeadline() {
    if (previewIsFollowUp()) {
      return "Don't miss your new tiles";
    } else {
      return 'Your New Tiles Are Here!';
    }
  }

  function updateCustomHeadline(event) {
    var value;
    value = $(this).val();
    if (value === '') {
      value = defaultCustomHeadline();
    }
    return $('#digest_management #share_tiles_digest_preview').contents().find('#custom_headline').html(value);
  }

  function resizeEmailPreview() {
    var maxHeight, newHeight, newTotalHeight, newWidth;
    newHeight = document.getElementById('share_tiles_digest_preview').contentWindow.document.body.scrollHeight;
    maxHeight = $('#digest_management').find('.notification_controls').height();
    newWidth = document.getElementById('share_tiles_digest_preview').contentWindow.document.body.scrollWidth;
    $('#share_tiles_digest_preview').height(newHeight + "px");
    $('#share_tiles_digest_preview').width(newWidth + "px");
    newTotalHeight = $('.large-9.digest_preview').height();
    if (newTotalHeight > maxHeight) {
      newHeight -= newTotalHeight - maxHeight;
      $('#share_tiles_digest_preview').height(newHeight + "px");
    }

    window.resizedEmailPreview = true;
  }

  function manageUsers() {
    $('#digest_include_sms').on('change', function(e) {
      var ischecked = $(this).is(':checked');
      if (ischecked) {
        $(".sms-recipients").show();
      } else {
        $(".sms-recipients").hide();
      }

      resizeEmailPreview();
    });

    $('#digest_digest_send_to').on('change', function(event) {
      if ($('#digest_digest_send_to option:selected').text() === "All Users") {
        $('.js-all-user-recipients').show();
        $('.js-all-activated-user-recipients').hide();
      } else if ($('#digest_digest_send_to option:selected').text() === "Activated Users") {
        $('.js-all-user-recipients').hide();
        $('.js-all-activated-user-recipients').show();
      }
    });

    if ($('#digest_include_sms').is(':checked')) {
      $(".sms-recipients").show();
    }

    $('#digest_digest_send_to').trigger('change');
  }

  function init() {
    $('#digest_include_sms').show();
    manageUsers();
    loadDigestPreview();

    $(".js-digest-preview-tabs li").click(function(e) {
      e.preventDefault();
      $(".digest_preview_overlay").fadeIn();

      $(".js-digest-preview-tabs li").removeClass("tabs-component-active");
      $(this).addClass("tabs-component-active");

      loadDigestPreview($(this).data("previewType"));
    });

    $('#share_tiles_digest_preview').on('load', function(event) {
      if (!window.resizedEmailPreview) {
        resizeEmailPreview();
      }

      if ($("#show_sms_preview").hasClass("tabs-component-active")) {
        $(".email-client").addClass("phone");
      } else {
        $(".email-client").removeClass("phone");
      }

      $(".digest_preview_overlay").fadeOut();
      return $("#digest_custom_message, #digest_custom_subject, #digest_custom_headline").trigger('keyup');
    });

    $('#digest_management').find('#digest_custom_message').on('keyup', function(event) {
      return $('#digest_management').find('#share_tiles_digest_preview').contents().find('#custom_message').html($(this).val());
    }).on('keypress', function(event) {
      return $('#digest_management').find('#share_tiles_digest_preview').contents().find('#custom_message').html($(this).val());
    });

    $('#digest_management #digest_custom_headline').on('keyup', updateCustomHeadline).on('keypress', updateCustomHeadline);

    $('#digest_custom_subject').keyup(function(event) {
      var text;
      text = $(event.target).val();
      return $('.subject-field').text(textForSubject(text));
    });

    $("#send_test_digest").click(function(e) {
      e.preventDefault();
      $("#digest_type").val("test_digest");
      return $("#tiles_digest_form").submit();
    });
  }

  return {
    init: init
  };

}());

$(function() {
  if (Airbo.Utils.nodePresent(".js-client-admin-tiles-digest-management")) {
    Airbo.TilesDigestManagement.init();
  }
});
