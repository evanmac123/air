var Airbo = window.Airbo || {};

Airbo.ImageLoadingPlaceholder = (function(){
  function removeLoadingPlaceholder() {
    $(".tile_full_image").removeClass("loading").attr("style", "");
  }
  function loadImage() {
    if( $("#tile_img_preview")[0].complete ) {
      removeLoadingPlaceholder();
    }else{
      $("#tile_img_preview").on("load", function(){
        removeLoadingPlaceholder();
      });
    }
  }
  function init() {
    loadImage();
  }
  return {
    init: init
  }
}());
