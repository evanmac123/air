var Airbo = window.Airbo || {};

Airbo.Campaigns = (function(){
  var id;
  var path;

  function bindAddNewChannelForm() {
    $('#new-campaign').click(function(event) {
      event.preventDefault();
      addNewChannel($(this));
    });
  }

  function addNewChannel(self) {
    if ($(".new_campaign").length === 0) {
      Airbo.Utils.ButtonSpinner.trigger(self);
      $.get("/admin/campaigns/new").done(function(data) {
        $('#new-campaign-container').prepend(data.html);

        $(".create_campaign").unbind();
        $(".create_campaign").on("click", function(e) {
          routeForm($(this), "POST");
        });

        Airbo.Utils.ButtonSpinner.reset(self);
      });
    }
  }

  function initForm() {
    $(".update_campaign").on("click", function(e) {
      routeForm($(this), "PUT");
    });
  }

  function routeForm(submission, method) {
    var form = submission.parents("form");
    submitForm(form, submission, method);
  }

  function submitForm(form, self, method) {
    Airbo.Utils.ButtonSpinner.trigger(self);

    var formData = new FormData(form[0]);
    $.ajax({
      type: method,
      url: form.attr("action"),
      data: formData,
      processData: false,
      contentType: false,
    }).done(function(data) {
      var form = self.parents("form");
      if (data.errors) {
        form.children("#response_explanation").text(data.errors).css("color", "red");
        Airbo.Utils.ButtonSpinner.completeError(self);
      } else {
        if (method === "POST") {
          $.get("/admin/campaigns/" + data.campaign.id).done(function(data) {
            $(".new-campaign-section").remove();
            $('#campaign-container').prepend(data.html);

            $(".update_campaign").unbind();
            $(".update_campaign").on("click", function(e) {
              routeForm($(this), "PUT");
            });
          });
        } else {
          form.children(".image-row").children(".campaign-image-container").css("background-image", "url(" + data.campaign.image_url + ")");
        }

        Airbo.Utils.ButtonSpinner.completeSuccess(self, true);
      }
    });
  }

  function init() {
    bindAddNewChannelForm();
    initForm();
  }

  return {
    init: init
  };
}());

$(function() {
  if ($(".admin-campaigns").length > 0) {
    Airbo.Campaigns.init();
  }
});
