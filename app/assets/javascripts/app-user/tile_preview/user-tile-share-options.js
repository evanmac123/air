var Airbo = window.Airbo || {};

Airbo.UserTileShareOptions = (function() {
  function init() {
    initSocialShareLinks($(".social-share"));
    initSharePings();
  }

  function initSocialShareLinks($selector) {
    jsSocials.setDefaults("pinterest", {
      media: $("meta[property='og:image']").attr("content")
    });

    jsSocials.setDefaults("twitter", {
      hashtags: $selector.data("twitterHashtags")
    });

    $selector.jsSocials({
      url: $selector.data("tilePath"),
      text: $selector.data("shareText"),
      shareIn: "blank",
      showLabel: false,
      showCount: false,
      shares: ["email", "linkedin", "twitter", "facebook", "pinterest"]
    });
  }

  function initSharePings() {
    $(".jssocials-share").on("click", function(e) {
      sharePing($(this).attr("class"));
    });

    $(".share-link").one("focusin", function(e) {
      sharePing($(this).attr("class"));
    });
  }

  function sharePing(shareOption) {
    Airbo.Utils.ping("Tile Sharing", {
      action: "Share option clicked",
      shareOption: shareOption
    });
  }

  return {
    init: init
  };
})();
