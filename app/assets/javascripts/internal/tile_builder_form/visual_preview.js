var Airbo = window.Airbo || {}

Airbo.TileVisualPreviewMgr = (function(){

  function hideImageWrapper(){
    $(".images-wrapper").hide();
  }

  function showImageWrapper(){
    $(".images-wrapper").show();
  }

  function showEmbedVideo(){
    $(".embed-video-container").show();
  }

  function hideEmbedVideo(){
    $(".embed-video-container").hide();
  }

  function hideVisualContentPanel(){
    $(".visual-content-container").slideUp();
    hideImageWrapper();
    hideEmbedVideo();
  }

  function resetEmbedVideo(){
    $("#embed_video_field").val("");
  }

  function initHideVisualContent(){
    $("body").on("click", ".hide-search", function(event){
      resetSearchInput();
      hideVisualContentPanel();
    });
  }

  function showVisualContentPanel(){
    $(".visual-content-container").slideDown();
  }

  function initShowVideoPanel(){
    $("body").on("click", ".img-menu-item.video", function(event){
      hideImageWrapper();
      resetSearchInput();
      showEmbedVideo();
      showVisualContentPanel();
    });
  }

  function showImages(){

  }
  function showSearchResults() {
    showImageWrapper();
    showVisualContentPanel();
  }

  function initVisualContent(){
    initHideVisualContent();
    initShowVideoPanel();
    initShowSearchInput();
  }

  function init(){
    $.Topic("image-results-added").subscribe( function(){
      showSearchResults();
    });
    initVisualContent();
    initShowSearchInput();
  }

  function resetSearchInput(){
    $(".search-input").val("").animate({width:'0px'}, 600, "linear")
  }


  function initShowSearchInput(){
    $("body").on("click", ".show-search", function(event){
      $(".search-input").animate({width:'200px'}, 600, "linear")

      hideEmbedVideo();
      resetEmbedVideo();
    })
  }
  return {
    init: init,
    showImages, showImages,
  }
}());

