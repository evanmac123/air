var Aiebo = window.Airbo || {};
// FIXME This was simply ported from the global namespace in erb... Original implementaion relies heavily on code in form_with_clearable_fielf.js, which is shit.

Airbo.EditBoardSettings = (function() {
  function initCharacterCounters() {
    ["#demo_persistent_message"].forEach(function(sel) {
      window.addCharacterCounterFor(sel);
    });
  }

  function initClearableForms() {
    [
      "#demo_persistent_message",
      "#demo_public_slug",
      "#demo_name",
      "#demo_custom_reply_email_name",
      "#demo_email",
      "#demo_cover_message",
      "#demo_timezone"
    ].forEach(function(sel) {
      window.formWithClearableTextField(sel);
    });
  }

  function initUpdateSettingsRadioForm() {
    $(".js-update-board-settings-radio").change(function() {
      $(this)
        .closest("form")
        .children(".js-board-settings-radio-submit")
        .attr("disabled", false);
      $(this)
        .closest("form")
        .addClass("dirty");
    });

    $(".js-board-settings-radio-form").submit(function(e) {
      e.preventDefault();
      var $form = $(this);
      var submitButton = $(this).children(".js-board-settings-radio-submit");
      submitButton.val("Updating...");
      $.ajax({
        url: $form.attr("action"),
        data: $form.serialize(),
        type: "PATCH"
      }).done(function() {
        $form.removeClass("dirty");
        submitButton.attr("disabled", true);
        submitButton.val("Update");
      });
    });
  }

  function initPublicLinkForm() {
    window.urlField("#demo_public_slug");
  }

  function initLogoUploadForm() {
    window.formWithClearableLogoField("#demo_logo");
  }

  function init() {
    initCharacterCounters();
    initClearableForms();
    initUpdateSettingsRadioForm();
    initPublicLinkForm();
    initLogoUploadForm();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-board-settings-module")) {
    Airbo.EditBoardSettings.init();
    Airbo.TabsComponentManager.init(
      ".js-board-settings-module",
      "Board Settings Page Action"
    );
  }
});
