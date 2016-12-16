var Airbo = window.Airbo || {};

Airbo.ShowMoreContent = (function() {
  function initMoreTiles(selector) {
    $(selector).one("click", function(e) {
      e.preventDefault();
      var self = $(this);
      var attrs = {
        path: self.data("tile-path"),
        type: self.data("tile-type"),
        tileOffset: self.data("tile-count"),
        campaignOffset: null,
        contentType: self.data('contentType'),
        targetSelector: self.data('target-selector'),
        disabled: self.attr('disabled'),
        downArrowSelector: '.show_more_tiles_copy',
        spinnerSelector: '.show_more_tiles_spinner',
        updateMethod: 'append'
      };

      updateContent(self, attrs);
    });
  }

  function initMoreCampaigns(selector) {
    $(selector).one("click", function(e) {
      e.preventDefault();
      var self = $(this);
      var attrs = {
        path: self.data("campaign-path"),
        type: "campaign",
        tileOffset: null,
        campaignOffset: self.data("campaign-count"),
        contentType: self.data('contentType'),
        targetSelector: self.data('target-selector'),
        disabled: self.attr('disabled'),
        downArrowSelector: '.show_more_campaigns_copy',
        spinnerSelector: '.show_more_campaigns_spinner',
        updateMethod: 'append'
      };

      updateContent(self, attrs);
    });
  }

  function updateContent(self, attrs) {
    $(attrs.downArrowSelector).hide();
    $(attrs.spinnerSelector).show();

    $.get(attrs.path, { tile_offset: attrs.tileOffset, campaign_offset: attrs.campaignOffset, partial_only: 'true', content_type: attrs.type }, (function(data) {
      var content = data.htmlContent || data;
      $(attrs.spinnerSelector).hide();
      $(attrs.downArrowSelector).show();
      resetBindings();
      $(attrs.targetSelector).append(content);
      updateOffsets(self, attrs, data);
      Airbo.CopyTileToBoard.init();

      if (data.lastBatch) {
        $(self).attr('disabled', 'disabled');
      }

    }), attrs.contentType);
  }

  function updateOffsets(self, attrs, data) {
    if (attrs.tileOffset) {
      self.data().tileCount += data.objectCount;
    } else if (attrs.campaignOffset) {
      self.data().campaignCount += data.objectCount;
    }
  }

  function resetBindings() {
    $(".explore_show_more_campaigns").unbind();
    $(".explore_show_more_tiles").unbind();
    initMoreCampaigns(".explore_show_more_campaigns");
    initMoreTiles(".explore_show_more_tiles");
  }

  function initEvents() {
    initMoreTiles(".explore_show_more_tiles");
    initMoreCampaigns(".explore_show_more_campaigns");
  }

  function init() {
    initEvents();
  }

  return {
    init: init
  };

}());

$(function(){
  if( $(".tile_wall_explore").length > 0 ) {
    Airbo.ShowMoreContent.init();
  }
});
