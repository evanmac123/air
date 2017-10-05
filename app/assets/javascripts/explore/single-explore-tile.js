var Airbo = window.Airbo || {};

Airbo.ExploreSingleTile = (function(){
  var entryPoint;
  var tileType;

  function initSocialShareLinks($selector) {
    jsSocials.setDefaults("pinterest", {
    	media: $("meta[property='og:image']").attr("content")
    });

    jsSocials.setDefaults("twitter", {
      hashtags: $entryPoint.data("twitterHashtags")
    });

    $selector.jsSocials({
      url: $entryPoint.data("tilePath"),
      shareIn: "blank",
      showLabel: false,
      showCount: false,
      shares: ["email", "linkedin", "twitter", "facebook", "pinterest"]
    });
  }

  function initAnswerCorrectModal() {
    $(".js-multiple-choice-answer.correct, .clicked_right_answer").on("click", function(e) {
      e.preventDefault();
      if($(this).hasClass("free-text")) {
        if(!$(".js-free-form-response").val()) {
          return;
        }
      }

      if(tileType === "public") {
        publicTileCompleted();
      } else {
        exploreTileCompleted();
      }
    });
  }

  function publicTileCompleted() {
    Airbo.Utils.ping("Single Explore Tile", { action: "Completed Tile" });
    initAnswerCorrectModal();
    swal({
      title: "Tile Completed!",
      type: "success",
      showConfirmButton: false,
      showCancelButton: true,
      cancelButtonText: "Close",
      customClass: "airbo",
      allowOutsideClick: true
    });
  }

  function exploreTileCompleted() {
    Airbo.Utils.ping("Single Explore Tile", { action: "Completed Tile" });
    initAnswerCorrectModal();
    swal({
      title: "Tile Completed 🎉",
      type: "success",
      cancelButtonText: "Close",
      showCancelButton: false,
      text: "",
      html: true,
      confirmButtonColor: "#4fd4c0",
      confirmButtonText: confirmButtonText($entryPoint.data("currentUserIsClientAdmin")),
      closeOnConfirm: true,
      customClass: "airbo",
      allowOutsideClick: true
    },
    function(isConfirm) {
      Airbo.Utils.ping("Single Explore Tile", { action: "clicked tile completed CTA", cta: $(this)[0].confirmButtonText });
      if(isConfirm) {
        var url = $entryPoint.data("moreContentUrl");
        var win = window.open(url, "_blank");
        if (win) {
          win.focus();
        } else {
          window.location.href = url;
        }
      }
    });
  }

  function confirmButtonText(isClientAdmin) {
    return "See More";
  }

  function initPingEvents() {
    $(".jssocials-share").on("click", function(e) {
      Airbo.Utils.ping("Single Explore Tile", { action: "Share option clicked", shareOption: $(this).attr("class") });
    });

    $(".share-link").one("focusin", function(e) {
      Airbo.Utils.ping("Single Explore Tile", { action: "Share option clicked", shareOption: $(this).attr("class") });
    });
  }

  function init() {
    $entryPoint = $(".js-single-tile-base");
    tileType = $entryPoint.data("exploreOrPublic");

    initSocialShareLinks($(".social-share"));
    initAnswerCorrectModal();
    initPingEvents();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".single-tile-base")) {
    Airbo.ExploreSingleTile.init();
  }
});