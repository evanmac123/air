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

  function hideLoader(){
    $(".endless_scroll_loading").hide();
  }

  function showLoader(){
    $(".endless_scroll_loading").show();
  }


  function hideUnparsableError(){
    $(".unparsable").hide();
  }

  function showUnparsableError(){
    $(".unparsable").show();
  }

  function hideUnloadableError(){
    $(".unloadable").hide();
  }

  function hideVisualContentPanel(){
    $(".visual-content-container").slideUp();
    hideImageWrapper();
    hideEmbedVideo();
    $(".hide-search").hide();
  }

  function hideVideoErrors(){
    hideLoader();
    hideUnloadableError();
    hideUnparsableError();
  }



  function showVisualContentPanel(){
    $(".hide-search").show();
    $(".visual-content-container").slideDown();
  }


  function toggleOffVideo(){
    hideEmbedVideo();
  }


  function showSearchResults() {
    showVisualContentPanel();
    showImageWrapper();
  }

  function initShowVideoPanel(){
    $("body").on("click", ".img-menu-item.video", function(event){
      hideImageWrapper();
      resetSearchInput();
      showEmbedVideo();
      hideVideoErrors();
      showVisualContentPanel();
    });
  }

  function initVisualContent(){
    initHideVisualContent();
    initShowVideoPanel();
  }

  function initCustomEventsSubscriber(){

    $.Topic("image-results-added").subscribe( function(){
      hideLoader();
    });

    $.Topic("video-added").subscribe( function(){
      hideVisualContentPanel()
      hideLoader();
      $(".video_section").show();
      $("#image_uploader").hide();
    });

    $.Topic("video-link-entered").subscribe(function(){
      showLoader(); 
    });

    $.Topic("video-link-cleared").subscribe(function(){
      hideVideoErrors()
    })


    $.Topic("video-load-error").subscribe(function(){
      hideLoader();
      $(".unloadable").show();
    });


    $.Topic("video-removed").subscribe( function(){
      $("#image_uploader").show();
      hideVideoPreview();
    });

    $.Topic("video-link-parse-error").subscribe(function(){
      showUnparsableError();
    });

    $.Topic("inititiating-image-search").subscribe( function(){
      $("#remote_media_url").val("");
      $("#tile_builder_form_embed_video").val("");
      hideVideoPreview();
      hideEmbedVideo();
      showSearchResults();
      showLoader(); 
    });
  }

  function initPreviewByType(){
    if( $("#tile_builder_form_embed_video").val().length > 0 ) {
      $("#image_uploader").hide();
      showVideoPreview()
    }
  }

  function initHideVisualContent(){
    $("body").on("click", ".hide-search", function(event){
      resetSearchInput();
      hideVisualContentPanel();

      if($(".unparsable").is(":visible")){
        $("#remote_media_url").val("");
        $("#tile_builder_form_embed_video").val("");
      }

    });
  }

  function init(){
    initCustomEventsSubscriber();
    initPreviewByType();
    initVisualContent();
  }


  return {
    init: init,
  }
}());

