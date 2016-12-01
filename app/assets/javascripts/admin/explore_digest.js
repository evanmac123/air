var Airbo = window.Airbo || {};

Airbo.ExploreDigest = (function(){
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
    $("#send_test_digest").on("click", function(e) {
      var self = $(this);
      var id = $("#digest_id").data("id");
      var path = '/admin/explore_digests/' + id + '/deliver';
      var params = { test_digest: true };
      deliver(path, self, params);
    });

    $("#send_real_digest").on("click", function(e) {
      var confirmed = confirm("Are you sure you want to send this digest?");

      if (confirmed === true) {
        var self = $(this);
        var id = $("#digest_id").data("id");
        var path = '/admin/explore_digests/' + id + '/deliver';
        var params = { test_digest: false };
        deliver(path, self, params);
      }
    });
  }

  function deliver(path, self, params) {
    Airbo.Utils.ButtonSpinner.trigger(self);
    $.post(path, params).done(function(data) {
      if (data.errors) {
        $("#error_explanation").text(data.errors);
        Airbo.Utils.ButtonSpinner.completeError(self);
      } else {
        Airbo.Utils.ButtonSpinner.completeSuccess(self, true);
      }
    });
  }

  function init() {
    bindAddExploreDigestFeatureForm();
    initMailerForms();
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
