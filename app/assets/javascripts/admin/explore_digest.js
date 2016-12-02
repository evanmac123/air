var Airbo = window.Airbo || {};

Airbo.ExploreDigest = (function(){
  var id;
  var path;

  function bindAddExploreDigestFeatureForm() {
    $('#add_feature').click(function(event) {
      event.preventDefault();
      var count = $(".feature-section").length + 1;
      addNewFeatureTemplate(count);
    });
  }

  function addNewFeatureTemplate(count) {
    $('.features-container').append('<div class="panel feature-section"><legend>Feature ' + count + '</legend><br><div class="add-feature-form"><label for="feature_' + count + '_headline">Headline</label><input id="feature_' + count + '_headline" name="features[' + count + '][headline]" type="text"><label for="feature_' + count + '_headline_icon_url">Headline Icon URL</label><input id="feature_' + count + '_headline_icon_url" name="features[' + count + '][headline_icon_url]" type="text"><label for="feature_' + count + '_feature_message">Feature Message</label><textarea columns="60" id="feature_' + count + '_feature_message" name="features[' + count + '][feature_message]" rows="5"></textarea><label for="feature_' + count + '_tile_ids">Tile Ids (in order and comma separated)</label><input id="features_' + count + '_tile_ids" name="features[' + count + '][tile_ids]" placeholder="1, 2, 3, 4, 5, 6" type="text"></div></div>');
  }

  function initMailerForms() {
    id = $("#digest_id").data("id");
    path = '/admin/explore_digests/' + id + '/deliver';

    $("#send_test_digest").on("click", function(e) {
      var self = $(this);
      var params = { test_digest: true, targeted_digest: { send: false } };
      deliver(path, self, params);
    });

    $("#send_real_digest").on("click", function(e) {
      var confirmed = confirm("Are you sure you want to send this digest?");

      if (confirmed === true) {
        var self = $(this);
        var params = { test_digest: false, targeted_digest: { send: false } };
        deliver(path, self, params);
      }
    });

    $("#send_targeted_digest").on("click", function(e) {
      var confirmed = confirm("Are you sure you want to send this digest?");

      if (confirmed === true) {
        var self = $(this);
        var user_ids = $("#targeted_digest_users").val();
        var params = { test_digest: false, targeted_digest: { send: true, users: user_ids  } };
        deliver(path, self, params);
      }
    });
  }

  function deliver(path, self, params) {
    Airbo.Utils.ButtonSpinner.trigger(self);
    $.post(path, params).done(function(data) {
      if (data.errors) {
        $("#response_explanation").text(data.errors).css("color", "red");
        Airbo.Utils.ButtonSpinner.completeError(self);
      } else {
        $("#response_explanation").text("Digest delivered").css("color", "#3c763d");
        Airbo.Utils.ButtonSpinner.completeSuccess(self, true);
      }
    });
  }

  function initForm() {
    $("#create_explore_digest").on("click", function(e) {
      routeForm($(this), "POST");
    });

    $("#update_explore_digest").on("click", function(e) {
      routeForm($(this), "PUT");
    });
  }

  function routeForm(submission, method) {
    var form = submission.parents("form");
    submitForm(form, submission, method);
  }

  function submitForm(form, self, method) {
    Airbo.Utils.ButtonSpinner.trigger(self);
    $.ajax({
      type: method,
      url: form.attr("action"),
      data: form.serialize()
    }).done(function(data) {
      if (data.errors) {
        $("#response_explanation").text(data.errors).css("color", "red");
        Airbo.Utils.ButtonSpinner.completeError(self);
      } else {
        $("#response_explanation").text("");
        Airbo.Utils.ButtonSpinner.completeSuccess(self, true);
        if (method === "POST") {
          var id = data.explore_digest.id;
          window.location = "/admin/explore_digests/" + id + "/edit";
        }
      }
    });
  }

  function initInputChangeEvent() {
    var input = $("input");
    input.on("change", function() {
      Airbo.Utils.ButtonSpinner.reset($(".explore_digest_persist"));
    });
  }

  function init() {
    bindAddExploreDigestFeatureForm();
    initMailerForms();
    initForm();
    initInputChangeEvent();
  }

  return {
    init: init
  };
}());

$(function() {
  if ($(".admin-explore_digests").length > 0) {
    Airbo.ExploreDigest.init();
  }
});
