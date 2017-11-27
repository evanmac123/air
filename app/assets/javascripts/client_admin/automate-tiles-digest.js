var Airbo = window.Airbo || {};
Airbo.ClientAdmin = Airbo.ClientAdmin || {};

Airbo.ClientAdmin.AutomateTilesDigest = (function(){

  function frequencyText() {
    $("#tiles_digest_automator_frequency_cd option[selected]").text();
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
      $("#tiles_digest_automator_day").hide();
    } else {
      $("#tiles_digest_automator_day").show();
    }
  }

  function submitUpdate() {
    debugger
  }

  function bindEvents() {
    $("#tiles_digest_automator_frequency_cd").on("change", function(e) {
      manageGrammer($(this).find("option:selected").text());
    });

    $(".js-update-tiles-digest-automator").on("click", function(e) {
      e.preventDefault();
      submitUpdate();
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
