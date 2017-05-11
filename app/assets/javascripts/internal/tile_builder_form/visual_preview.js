var Airbo = window.Airbo || {}

Airbo.TileVisualPreviewMgr = (function(){

  function hideImageWrapper(){
    $(".images-wrapper").hide();
  }

  function showImageWrapper(){
    $(".images-wrapper").show();
  }

  function showEmbedVideo(){
    $(".embed-video-container").addClass("present").show();
    $("#tile_builder_form_embed_video").focus();
  }

  function hideEmbedVideo(){
    $(".embed-video-container").removeClass("present").hide();
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

  function emptyImages(){
   var grid = $("#images")
   if(grid.data('flickity')){
     grid.flickity('destroy');
   }
   grid.empty();
  }

  function hideVisualContentPanel(){
    var dest = jQuery('.image_preview').offset().top;
    $(".visual-content-container").slideUp();
    hideImageWrapper();
    hideEmbedVideo();
    $('.reveal-modal').animate({ scrollTop: 0 }, 700);
  }

  function hideVideoErrors(){
    hideLoader();
    hideUnloadableError();
    hideUnparsableError();
  }



  function showVisualContentPanel(){
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
      emptyImages();
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

  function showMediaPanelCloseButton(){
    $(".hide-media-panel-button").show();
  }


  function hideMediaPanelCloseButton(){
    $(".hide-media-panel-button").hide();
  }

  function initCustomEventsSubscriber(){

    Airbo.PubSub.subscribe("image-results-added", function(){
      hideLoader();
    });

    Airbo.PubSub.subscribe("video-added", function(){
      hideVisualContentPanel()
      hideLoader();
      $(".video_section").show();
      $("#image_uploader").hide();
    });

    Airbo.PubSub.subscribe("video-link-entered", function(){
      showLoader();
    });

    Airbo.PubSub.subscribe("video-link-cleared", function(){
      hideVideoErrors()
    })


    Airbo.PubSub.subscribe("video-load-error", function(){
      hideLoader();
      $(".unloadable").show();
    });


    Airbo.PubSub.subscribe("video-removed", function(){
      $("#image_uploader").show();
      hideLoader();
      hideVideoPreview();
    });

    Airbo.PubSub.subscribe("video-link-parse-error", function(){
      hideLoader();
      showUnparsableError();
    });


    Airbo.PubSub.subscribe("media-request-done", function(){
      showMediaPanelCloseButton();
    });

    Airbo.PubSub.subscribe("inititiating-image-search", function(){
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
    $("body").on("click", ".hide-media-panel-button", function(event){
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
