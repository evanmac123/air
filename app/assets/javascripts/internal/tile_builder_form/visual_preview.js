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

    $.Topic("video-added").subscribe( function(){
      toggleVideoSection(true)
      $("#image_uploader").hide();
    });

    $.Topic("video-removed").subscribe( function(){
      $("#image_uploader").show();
      toggleVideoSection(false)
    });

    initPreviewByType();
    initVisualContent();
    initShowSearchInput();
  }

  function resetSearchInput(){
    $(".search-input").val("").animate({width:'0px'}, 600, "linear")
  }

  function openSearch(){
    $(".search-input").animate({width:'200px'}, 600, "linear")
  }


  function initPreviewByType(){
    if( $("#tile_builder_form_embed_video").val().length > 0 ) {
      $("#image_uploader").hide();
      toggleVideoSection(true);
    }
    autosize( $("#embed_video_field") );
  }

  function toggleOffVideo(){
      hideEmbedVideo();
      resetEmbedVideo();
  }

  function toggleVideoSection(show) {
    if(show) {
      $(".video_section").removeClass("hidden");
      setTimeout(function(){
        $(".error_no_video").show();
      }, 1000);
    } else {
      $(".video_section").addClass("hidden");
      setTimeout(function(){
        $(".error_no_video").hide();
      }, 1000);
    }
  }

  function initShowSearchInput(){
    $("body").on("click", ".show-search", function(event){
      toggleOffVideo();
      openSearch();
    })
  }
  return {
    init: init,
    showImages, showImages,
  }
}());

