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
   $("#tile_builder_form_embed_video").focus();
  }

  function hideEmbedVideo(){
    $(".embed-video-container").hide();
  }

  function hideVisualContentPanel(){
    $(".visual-content-container").slideUp();
    hideImageWrapper();
    hideEmbedVideo();
    $(".hide-search").hide();
  }


  function initHideVisualContent(){
    $("body").on("click", ".hide-search", function(event){
      resetSearchInput();

      $.Topic("media-input-hidden").publish();
      hideVisualContentPanel();
    });
  }

  function showVisualContentPanel(){
    $(".hide-search").show();
    $(".visual-content-container").slideDown();
  }


  function showVideoPreview(){
    $(".video_section").show();
  }

  function hideVideoPreview(){
    $(".video_section").hide();
  }


  function resetSearchInput(){
    $(".search-input").val("");
  }

  function openSearch(){
    $(".search-input").animate({width:'200px'}, 500, "linear", function(){
      $(".search-input").addClass("isOpen").focus();
    });
  }

  function toggleOffVideo(){
    hideEmbedVideo();
  }


  function showSearchResults() {
    showImageWrapper();
    showVisualContentPanel();
  }

  function initShowVideoPanel(){
    $("body").on("click", ".img-menu-item.video", function(event){
      hideImageWrapper();
      resetSearchInput();
      showEmbedVideo();
      showVisualContentPanel();
    });
  }

  function initVisualContent(){
    initHideVisualContent();
    initShowVideoPanel();
  }

  function init(){
    $.Topic("image-results-added").subscribe( function(){
      showSearchResults();
    });

    $.Topic("video-added").subscribe( function(){
      hideVisualContentPanel()
      $(".video_section").show();
      $("#image_uploader").hide();
    });

    $.Topic("video-removed").subscribe( function(){
      $("#image_uploader").show();
      hideVideoPreview();
    });

    initPreviewByType();
    initVisualContent();
  }

  function initPreviewByType(){
    if( $("#tile_builder_form_embed_video").val().length > 0 ) {
      $("#image_uploader").hide();
      showVideoPreview()
    }
  }


  return {
    init: init,
  }
}());

