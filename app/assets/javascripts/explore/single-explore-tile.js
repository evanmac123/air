var Airbo = window.Airbo || {};

Airbo.ExploreSingleTile = (function(){
  var entryPoint;
  var tileType;

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

  function init() {
    $entryPoint = $(".js-single-tile-base");
    tileType = $entryPoint.data("exploreOrPublic");

    Airbo.UserTileShareOptions.init();
    initAnswerCorrectModal();
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
