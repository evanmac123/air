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
        success: function(data) {
          var rowTemplate = HandlebarsTemplates[
            "client-admin/populationSegmentRow"
          ]({ segment: data.population_segment });

          $(".js-population-segments table").append(rowTemplate);
          $("#population_segment_name").val("");
        }
      });
    });
  }

  function renderPopulationSegmentsTable() {
    var data = $(".js-population-segments").data();
    var template = HandlebarsTemplates["client-admin/populationSegmentsTable"](
      data
    );

    $(".js-population-segments").append(template);
  }

  function initDelete() {
    $("body").on("click", ".js-delete-segment", function(e) {
      var segmentId = $(this).data("segmentId");
      var $segmentRow = $(this).parents("tr");
      e.preventDefault();

      if (confirm("Are you sure you want to delete this Population Segment?")) {
        $.ajax({
          type: "DELETE",
          url: "/api/client_admin/population_segments/" + segmentId,
          success: function() {
            $segmentRow.remove();
          }
        });
      }
    });
  }

  function init() {
    renderPopulationSegmentsTable();
    initForm();
    initDelete();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-population-segments-component")) {
    Airbo.ClientAdmin.PopulationSegmentsComponent.init();
  }
});
