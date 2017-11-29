var Airbo = window.Airbo || {};
Airbo.ClientAdmin = Airbo.ClientAdmin || {};

Airbo.ClientAdmin.AutomateTilesDigest = (function(){

  function automatorId() {
    return $(".js-share-automate-component").data("automatorId");
  }

  function automatorPersited() {
    return automatorId() !== "";
  }

  function formPath() {
    if (automatorPersited()) {
      return "/api/client_admin/tiles_digest_automators/" + automatorId();
    } else {
      return "/api/client_admin/tiles_digest_automators";
    }
  }

  function formMethod() {
    if (automatorPersited()) {
      return "PUT";
    } else {
      return "POST";
    }
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
    $.ajax({
      url: formPath(),
      data: $form.serialize(),
      type: formMethod(),
      success: function(result) {
        $(".js-share-automate-component").data("automatorId", result.id);
        $(".js-remove-tiles-digest-automator").show();
        $(".js-update-tiles-digest-automator").val("Update");
        $(".js-last-sent-at").addClass("scheduled");
        $(".js-last-sent-at").text(result.sendAtTime);
      }
    });
  }

  function submitRemove() {
    $.ajax({
      url: formPath(),
      type: 'DELETE',
      success: function(result) {
        $(".js-remove-tiles-digest-automator").hide();
        $(".js-update-tiles-digest-automator").val("Schedule Tiles Digests");
        $(".js-last-sent-at").removeClass("scheduled");
        $(".js-last-sent-at").text(result.sendAtTime);
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
