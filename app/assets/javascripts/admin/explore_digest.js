var Airbo = window.Airbo || {};

Airbo.ExploreDigest = (function(){
  function bindAddExploreDigestTileIDField() {
    $('#add_tile_id').click(function(event) {
      event.preventDefault();
      return $('#tile_ids_container').append('<input type="text" name="explore_digest_form[tile_ids][]">');
    });
  }

  function bindAddExploreDigestFeatureForm() {
    $('#add_feature').click(function(event) {
      event.preventDefault();
      var count = $(".feature-section").length + 1;
      return $('.features-container').append('<fieldset class="feature-section"> <legend>Feature</legend> <div class="add-feature-form"> <label for="feature_' + count + '_headline">Headline</label> <input id="feature_' + count + '_headline" name="feature[' + count + '][headline]" type="text"> <label for="feature_' + count + '_custom_message">Custom Message</label> <textarea columns="60" id="feature_' + count + '_custom_message" name="feature[' + count + '][custom_message]" rows="5"></textarea> <label for="feature_' + count + '_tile_ids">Tile IDs</label> <div id="feature_tile_ids_container"> <input id="feature_' + count + '_tile_ids_" name="feature[' + count + '][tile_ids][]" type="text"> <input id="feature_' + count + '_tile_ids_" name="feature[' + count + '][tile_ids][]" type="text"> <input id="feature_' + count + '_tile_ids_" name="feature[' + count + '][tile_ids][]" type="text"> <input id="feature_' + count + '_tile_ids_" name="feature[' + count + '][tile_ids][]" type="text"> </div> </div> </fieldset>');
    });
  }

  function init() {
    bindAddExploreDigestFeatureForm();
    bindAddExploreDigestTileIDField();
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
