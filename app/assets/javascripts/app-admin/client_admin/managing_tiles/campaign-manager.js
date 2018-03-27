var Airbo = window.Airbo || {};

Airbo.CampaignManager = (function() {
  function init() {
    $(".js-campaign-color-option").on("click", function() {
      var color = $(this).data("hexColor");
      $("#campaign_color").val(color);
    });

    $("#new_campaign").submit(function(e) {
      var $form = $(this);
      e.preventDefault();

      $.ajax({
        url: $form.attr("action"),
        data: $form.serialize(),
        type: $form.attr("method"),
        success: function(data) {
          location.reload();
        }
      });
    });
  }

  return {
    init: init
  };
})();
