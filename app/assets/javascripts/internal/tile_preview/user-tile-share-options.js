var Airbo = window.Airbo || {};

Airbo.UserTileShareOptions = (function(){

  function init() {
    initSocialShareLinks($(".social-share"));
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
      shareIn: "blank",
      showLabel: false,
      showCount: false,
      shares: ["email", "linkedin", "twitter", "facebook", "pinterest"]
    });
  }

  return {
    init: init
  };

}());
