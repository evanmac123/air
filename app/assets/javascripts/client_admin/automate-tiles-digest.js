var Airbo = window.Airbo || {};
Airbo.ClientAdmin = Airbo.ClientAdmin || {};

Airbo.ClientAdmin.AutomateTilesDigest = (function(){

  function formPath() {
    return $(".js-share-automate-component").data("automatorUrl");
  }

  function frequencyText() {
    return $("#tiles_digest_automator_frequency_cd option[selected]").text();
  }

  function manageGrammer(frequency) {
    if(frequency === "Monthly") {
      Array.from($("#tiles_digest_automator_day option")).forEach(function(option) {
        $(option).text($(option).text().replace('on', 'on the first'));
      });
    } else {
      Array.from($("#tiles_digest_automator_day option")).forEach(function(option) {
        $(option).text($(option).text().replace('on the first', 'on'));
      });
    }

    if(frequency === "Daily") {
      $(".day-flex-group").hide();
    } else {
      $(".day-flex-group").show();
    }
  }

  function submitForm($form) {
    $(".js-update-tiles-digest-automator").addClass("with_spinner");

    $.ajax({
      url: formPath(),
      data: $form.serialize(),
      type: $form.attr("method"),
      success: function(result) {
        $(".js-share-automate-component").data("automator", result.tiles_digest_automator);
        $(".js-remove-tiles-digest-automator").show();
        $(".js-update-tiles-digest-automator").removeClass("with_spinner");
        $(".js-update-tiles-digest-automator").text("Update");
        $(".js-last-sent-at").addClass("scheduled");
        $(".js-last-sent-at").text(result.helpers.sendAtTime);
      }
    });
  }

  function submitRemove() {
    $(".js-remove-tiles-digest-automator").addClass("with_spinner");

    $.ajax({
      url: formPath(),
      type: 'DELETE',
      success: function(result) {
        $(".js-remove-tiles-digest-automator").hide();
        $(".js-remove-tiles-digest-automator").removeClass("with_spinner");
        $(".js-update-tiles-digest-automator").text("Schedule Tiles Digests");
        $(".js-last-sent-at").removeClass("scheduled");
        $(".js-last-sent-at").text(result.helpers.sendAtTime);
      }
    });
  }

  function bindEvents() {
    $("#tiles_digest_automator_frequency_cd").on("change", function(e) {
      manageGrammer($(this).find("option:selected").text());
    });

    $(".js-update-tiles-digest-automator").on("click", function(e) {
      e.preventDefault();
      submitForm($(this).closest("form"));
    });

    $(".js-remove-tiles-digest-automator").on("click", function(e) {
      e.preventDefault();
      submitRemove();
    });
  }

  function init() {
    manageGrammer(frequencyText());
    bindEvents();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".js-share-automate-component")) {
    Airbo.ClientAdmin.AutomateTilesDigest.init();
  }
});
