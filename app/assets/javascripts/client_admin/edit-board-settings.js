var Aiebo = window.Airbo || {};
// FIXME This was simply ported from the global namespace in erb... Original implementaion relies heavily on code in form_with_clearable_fielf.js, which is shit.

Airbo.EditBoardSettings = (function() {

  function initCharacterCounters() {
    ["#demo_persistent_message"].forEach(function(sel) {
      window.addCharacterCounterFor(sel);
    });
  }

  function initClearableForms() {
    ["#demo_persistent_message", "#demo_public_slug", "#demo_name", "#demo_logo", "#demo_custom_reply_email_name", "#demo_email", "#demo_cover_message", "#demo_timezone"].forEach(function(sel) {
      window.formWithClearableTextField(sel);
    });
  }

  function initWeeklyActivitySettingsForm() {
    $(".js-activity-report-pref").change(function() {
      $("#report_submit").attr("disabled", false);
      $("#weekly_activity_email").addClass("dirty");
    });

    $("#weekly_activity_email").submit(function(e){
      e.preventDefault();
      var submitButton = $("#report_submit");
      submitButton.val("Updating...");
      $.ajax({
        url: $(this).attr("action"),
        data: $(this).serialize(),
        type: "PUT"
      }).done(function(){
        $("#weekly_activity_email").removeClass("dirty");
        $("#report_submit").attr("disabled", true);
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
    initWeeklyActivitySettingsForm();
    initPublicLinkForm();
    initLogoUploadForm();
  }

  return {
    init: init
  };

}());

$(function() {
  if (Airbo.Utils.nodePresent(".js-edit-board-settings")) {
    Airbo.EditBoardSettings.init();
  }
});
