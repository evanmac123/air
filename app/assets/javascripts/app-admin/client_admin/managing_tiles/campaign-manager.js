var Airbo = window.Airbo || {};

Airbo.CampaignManager = (function() {
  function init() {
    $(".js-create-campaign").on("click", function() {
      $(".js-create-campaign-modal").foundation("reveal", "open");
    });

    $(".js-campaign-color-option").on("click", function() {
      var color = $(this).data("hexColor");
      $(".js-campaign-color").val(color);
    });

    $("#new_campaign, .js-edit-campaign-form").submit(function(e) {
      var $form = $(this);
      e.preventDefault();
      submitForm($form);
    });
  }

  function loadEditModal(data) {
    $(".js-edit-campaign-modal form").attr(
      "action",
      "/api/client_admin/campaigns/" + data.id
    );

    $(".js-edit-campaign-modal #campaign_name").val(data.name);
    $(".js-edit-campaign-modal #campaign_color").val(data.color);

    $(".js-edit-campaign-modal").foundation("reveal", "open");
  }

  function submitForm($form) {
    $.ajax({
      url: $form.attr("action"),
      data: $form.serialize(),
      type: $form.attr("method"),
      success: function(data) {
        location.reload();
      }
    });
  }

  return {
    init: init,
    loadEditModal: loadEditModal
  };
})();
