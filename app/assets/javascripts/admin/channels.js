var Airbo = window.Airbo || {};

Airbo.Channels = (function(){
  var id;
  var path;

  function bindAddNewChannelForm() {
    $('#new-channel').click(function(event) {
      event.preventDefault();
      addNewChannel($(this));
    });
  }

  function addNewChannel(self) {
    if ($(".new_channel").length === 0) {
      Airbo.Utils.ButtonSpinner.trigger(self);
      $.get("/admin/channels/new").done(function(data) {
        $('#new-channel-container').prepend(data.html);

        $(".create_channel").unbind();
        $(".create_channel").on("click", function(e) {
          routeForm($(this), "POST");
        });

        Airbo.Utils.ButtonSpinner.reset(self);
      });
    }
  }

  function initForm() {
    $(".update_channel").on("click", function(e) {
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
          $.get("/admin/channels/" + data.channel.slug).done(function(data) {
            $(".new-channel-section").remove();
            $('#channel-container').prepend(data.html);

            $(".update_channel").unbind();
            $(".update_channel").on("click", function(e) {
              routeForm($(this), "PUT");
            });
          });
        } else {
          form.children(".image-row").children(".channel-image-container").css("background-image", "url(" + data.channel.image_url + ")");
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
  if ($(".admin-channels").length > 0) {
    Airbo.Channels.init();
  }
});
