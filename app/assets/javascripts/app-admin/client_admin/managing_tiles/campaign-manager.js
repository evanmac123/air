var Airbo = window.Airbo || {};

Airbo.CampaignManager = (function() {
  function init() {
    loadCreateModal();
  }

  function loadEditModal(data) {
    var templateData = {
      action: "/api/client_admin/campaigns/" + data.id,
      method: "PUT",
      modalTitle: "Edit Campaign",
      submitCopy: "Save",
      color: data.color,
      name: data.name
    };

    initModal(templateData);
  }

  function loadCreateModal() {
    $(".js-create-campaign").on("click", function() {
      var templateData = {
        action: "/api/client_admin/campaigns",
        method: "POST",
        modalTitle: "Create Campaign",
        submitCopy: "Create Campaign",
        color: "#ffb748",
        name: ""
      };

      initModal(templateData);
    });
  }

  function initModal(templateData) {
    var form = HandlebarsTemplates["client-admin/editCampaign"](templateData);

    $(".js-edit-campaign-modal").html(form);
    initColorPicker();
    initSubmit();

    $(".js-edit-campaign-modal").foundation("reveal", "open");
  }

  function initColorPicker() {
    $(".js-campaign-color-option").on("click", function() {
      var color = $(this).data("hexColor");
      $(".js-campaign-color").val(color);
    });
  }

  function initSubmit() {
    $(".js-edit-campaign-form").submit(function(e) {
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
    init: init,
    loadEditModal: loadEditModal
  };
})();
