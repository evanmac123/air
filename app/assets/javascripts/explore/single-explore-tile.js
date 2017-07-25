var Airbo = window.Airbo || {};

Airbo.ExploreSingleTile = (function(){

  function initSocialShareLinks($selector) {
    jsSocials.setDefaults("pinterest", {
    	media: $("meta[property='og:image']").attr("content")
    });

    jsSocials.setDefaults("twitter", {
      hashtags: "airbo"
    });

    $selector.jsSocials({
      url: $(".single_tile_explore_layout").data("exploreTilePath"),
      shareIn: "blank",
      showLabel: false,
      showCount: false,
      shares: ["email", "linkedin", "twitter", "facebook", "pinterest"]
    });
  }

  function initAnswerCorrectModal() {
    $(".multiple-choice-answer.correct, .clicked_right_answer").on("click", function(e) {
      e.preventDefault();
      exploreTileCompleted();
    });
  }

  function exploreTileCompleted() {
    Airbo.Utils.ping("Single Explore Tile", { action: "Completed Tile" });
    initAnswerCorrectModal();
    swal({
      title: "Tile Completed!",
      type: "success",
      cancelButtonText: "Close",
      showCancelButton: true,
      text: "Airbo helps HR create a workplace that employees love.",
      html: true,
      confirmButtonColor: "#4fd4c0",
      confirmButtonText: "See more great content",
      closeOnConfirm: true,
      customClass: "airbo",
      allowOutsideClick: true
    },
    function(isConfirm) {
      Airbo.Utils.ping("Single Explore Tile", { action: "Clicked to see more content" });
      if(isConfirm) {
        var url = $(".single_tile_explore_layout").data("moreContentUrl");
        var win = window.open(url, "_blank");
        if (win) {
          win.focus();
        } else {
          window.location.href = url;
        }
      }
    });
  }

  function init() {
    initSocialShareLinks($(".social-share"));
    initAnswerCorrectModal();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".single_tile_explore_layout")) {
    Airbo.ExploreSingleTile.init();
  }
});
