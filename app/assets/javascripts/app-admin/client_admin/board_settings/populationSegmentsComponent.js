var Airbo = window.Airbo || {};
Airbo.ClientAdmin = Airbo.ClientAdmin || {};

Airbo.ClientAdmin.PopulationSegmentsComponent = (function() {
  function initForm() {
    var $form = $("#new_population_segment");

    $form.submit(function(e) {
      e.preventDefault();

      $.ajax({
        type: "POST",
        url: $form.attr("action"),
        data: $form.serialize(),
        success: function(data) {}
      });
    });
  }

  function init() {
    initForm();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-population-segments-component")) {
    Airbo.PopulationSegmentsComponent.init();
  }
});
