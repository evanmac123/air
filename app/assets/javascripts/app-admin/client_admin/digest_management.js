var Aiebo = window.Airbo || {};

Airbo.TilesDigestManagement = (function() {
  function loadDigestPreview(srcData) {
    var path = srcData.path;
    var populationSegmentParams = {
      population_segment_id: $(".js-population-segment").val()
    };

    var params = $.param($.extend(srcData.params, populationSegmentParams));
    var previewSrc = path + "?" + params;

    $("#digest_management")
      .find("#share_tiles_digest_preview")
      .attr("src", previewSrc);
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
    if (text === "") {
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
      return "Your New Tiles Are Here!";
    }
  }

  function updateCustomHeadline(event) {
    var value;
    value = $(this).val();
    if (value === "") {
      value = defaultCustomHeadline();
    }
    return $("#digest_management #share_tiles_digest_preview")
      .contents()
      .find("#custom_headline")
      .html(value);
  }

  function resizeEmailPreview() {
    var maxHeight, newHeight, newTotalHeight, newWidth;
    newHeight = document.getElementById("share_tiles_digest_preview")
      .contentWindow.document.body.scrollHeight;
    maxHeight = $("#digest_management")
      .find(".notification_controls")
      .height();
    newWidth = document.getElementById("share_tiles_digest_preview")
      .contentWindow.document.body.scrollWidth;
    $("#share_tiles_digest_preview").height(newHeight + "px");
    $("#share_tiles_digest_preview").width(newWidth + "px");
    newTotalHeight = $(".large-9.digest_preview").height();
    if (newTotalHeight > maxHeight) {
      newHeight -= newTotalHeight - maxHeight;
      $("#share_tiles_digest_preview").height(newHeight + "px");
    }
  }

  function initRecipientChangeEvents() {
    manageRecipientChange();

    $("#digest_digest_send_to").on("change", function(event) {
      manageRecipientChange();
    });
  }

  function manageRecipientChange() {
    if ($("#digest_digest_send_to option:selected").text() === "All Users") {
      $(".js-all-user-recipients").show();
      $(".js-all-activated-user-recipients").hide();
    } else if (
      $("#digest_digest_send_to option:selected").text() === "Activated Users"
    ) {
      $(".js-all-user-recipients").hide();
      $(".js-all-activated-user-recipients").show();
    }
  }

  function initReceiveSmsChangeEvents() {
    $("#digest_include_sms").show();
    manageReceiveSmsCheckbox();

    $("#digest_include_sms").on("change", function(e) {
      manageReceiveSmsCheckbox();
      resizeEmailPreview();
    });
  }

  function manageReceiveSmsCheckbox() {
    if ($("#digest_include_sms").is(":checked")) {
      $(".sms-recipients").show();
    } else {
      $(".sms-recipients").hide();
    }
  }

  function initDigestPreviewTabs() {
    $(".js-digest-preview-tabs li").click(function(e) {
      e.preventDefault();
      loadPreviewTab($(this));
    });
  }

  function loadPreviewTab($tab) {
    $(".digest_preview_overlay").fadeIn();

    $(".js-digest-preview-tabs li").removeClass("tabs-component-active");
    $tab.addClass("tabs-component-active");
    loadDigestPreview($tab.data());
  }

  function initDigestPreviewLoadEvents() {
    $("#share_tiles_digest_preview").on("load", function(event) {
      resizeEmailPreview();
      removeEmailClientToolbarForSms();

      $(".digest_preview_overlay").fadeOut();

      $(
        "#digest_custom_message, #digest_custom_subject, #digest_custom_headline"
      ).trigger("keyup");
    });
  }

  function removeEmailClientToolbarForSms() {
    if ($("#show_sms_preview").hasClass("tabs-component-active")) {
      $(".email-client").addClass("phone");
    } else {
      $(".email-client").removeClass("phone");
    }
  }

  function initCustomeMessageChangeEvents() {
    $("#digest_management")
      .find("#digest_custom_message")
      .on("keyup", function(event) {
        $("#digest_management")
          .find("#share_tiles_digest_preview")
          .contents()
          .find("#custom_message")
          .html($(this).val());
      })
      .on("keypress", function(event) {
        $("#digest_management")
          .find("#share_tiles_digest_preview")
          .contents()
          .find("#custom_message")
          .html($(this).val());
      });
  }

  function initCustomeHeadlineChangeEvents() {
    $("#digest_management #digest_custom_headline")
      .on("keyup", updateCustomHeadline)
      .on("keypress", updateCustomHeadline);
  }

  function initCustomeSubjectChangeEvents() {
    $("#digest_custom_subject").keyup(function(event) {
      var text;
      text = $(event.target).val();
      $(".subject-field").text(textForSubject(text));

      $("#digest_management")
        .find("#share_tiles_digest_preview")
        .contents()
        .find(".subject-field")
        .html(textForSubject(text));
    });

    $("#digest_custom_subject, #digest_alt_custom_subject").on(
      "keypress",
      function(e) {
        if (e.keyCode === 10 || e.keyCode === 13) {
          e.preventDefault();
        }
      }
    );
  }

  function initSendTestDigestEvents() {
    $("#send_test_digest").click(function(e) {
      e.preventDefault();
      $("#digest_type").val("test_digest");
      return $("#tiles_digest_form").submit();
    });
  }

  function initSaveDraftDigestEvents() {
    $("#save_draft_digest").click(function(e) {
      e.preventDefault();
      var $btn = $(this);
      $btn.html('<i class="fa fa-spinner fa-spin fa-fw"></i>');

      $.ajax({
        url: "/client_admin/tiles_digest_notification/save",
        type: "POST",
        dataType: "json",
        data: $("#tiles_digest_form").serialize()
      })
        .done(function(data) {
          $btn.html('<i class="fa fa-pencil-square-o"></i> Saved!');
          $btn.data("saved", true);
        })
        .fail(function() {
          window.location.reload();
        });
    });

    $("#tiles_digest_form :input").change(function() {
      var $btn = $("#save_draft_digest");

      if ($btn.data("saved") === true) {
        $btn.html('<i class="fa fa-pencil-square-o"></i> Save');
        $btn.data("saved", false);
      }
    });
  }

  function showDigestSentModal() {
    $(".js-digest-sent-modal").foundation("reveal", "open");
  }

  function initPopulationSegmentChange() {
    $("select.js-population-segment").on("change", function() {
      loadPreviewTab($(".js-digest-preview-tabs .tabs-component-active"));
    });
  }

  function init() {
    showDigestSentModal();
    loadDigestPreview($("#show_digest_preview").data());
    initReceiveSmsChangeEvents();
    initRecipientChangeEvents();
    initDigestPreviewTabs();
    initDigestPreviewLoadEvents();
    initCustomeMessageChangeEvents();
    initCustomeHeadlineChangeEvents();
    initCustomeSubjectChangeEvents();
    initSendTestDigestEvents();
    initSaveDraftDigestEvents();
    initPopulationSegmentChange();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-client-admin-tiles-digest-management")) {
    Airbo.TilesDigestManagement.init();
  }
});
