var Airbo = window.Airbo || {};

Airbo.ShowMoreContent = (function() {
  function initMoreTiles() {
    $(".explore_show_more_tiles").on("click", function(e) {
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

  function initMoreCampaigns() {
    $(".explore_show_more_campaigns").on("click", function(e) {
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
    if (attrs.disabled == 'disabled') { return; }

    $(attrs.downArrowSelector).hide();
    $(attrs.spinnerSelector).show();

    $.get(attrs.path, { tile_offset: attrs.tileOffset, campaign_offset: attrs.campaignOffset, partial_only: 'true', content_type: attrs.type }, (function(data) {
      var content = data.htmlContent || data;
      $(attrs.spinnerSelector).hide();
      $(attrs.downArrowSelector).show();
      switch (attrs.updateMethod) {
        case 'append':
          $(attrs.targetSelector).append(content);
        break;
        case 'replace':
          $(attrs.targetSelector).replaceWith(content);
      }

      if (data.lastBatch) {
        $(self).attr('disabled', 'disabled');
      }

    }), attrs.contentType);
  }

  function initEvents() {
    initMoreTiles();
    initMoreCampaigns();
  }

  function init() {
    initEvents();
  }

  return {
    init: init
  };

}());

$(function(){
  if( $("#tile_wall_explore").length > 0 ) {
    Airbo.ShowMoreContent.init();
  }
});
