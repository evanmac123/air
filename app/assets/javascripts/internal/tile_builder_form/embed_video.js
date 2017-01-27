var Airbo = window.Airbo || {};
//TODO clean this up to remove any deprecated functionality
Airbo.EmbedVideo = (function() {
  var modalObj = Airbo.Utils.StandardModal()
    , modalId = "embed_video_modal"
    , submitVideoSel = "#submit_embed_video"
    , submitVideo
    , modalInitialized = false
  ;
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
  function addVideoImage() {
    var videoImage = $("#remote_media_url").data("video-image");
    $("#remote_media_url").val(videoImage);
  }
  function removeVideoImage() {
    Airbo.TileImagesMgr.removeImage(); // image with video icon
  }
  function addVideo(embedCode) {
    $(".video_frame_block").html(embedCode);
    $("#image_uploader").hide();
    toggleVideoSection(true);
    addVideoImage();

    $("#tile_builder_form_embed_video").val(embedCode);
  }
  function removeVideo() {
    removeVideoImage();
    $("#image_uploader").show();
    toggleVideoSection(false);
    $(".video_frame_block").html("");
    $("#tile_builder_form_embed_video").val("");
  }
  function initFormEvents() {
    // form events
    $(".clear_video").click(function() {
      removeVideo();
    });

    $(".video_placeholder, .img-menu-item.video ").click(function() {
      //TODO add ping to 
      modalObj.open();
    });
  }
  function getValidCode(text) {
    text = $(text).filter("iframe").prop('outerHTML') || $(text).find("iframe").prop('outerHTML');
    return text;
  }
  function initModalEvents() {
    // modal events
    $("#embed_video_field").bind('input', function() {
      var embedCode =  getValidCode( $(this).val() );
      var blockSubmit = embedCode == undefined;
      if( !blockSubmit ) {
        $(this).val(embedCode);
      }
      submitVideo.prop("disabled", blockSubmit);
      $(".embed_video_err").toggle(blockSubmit);
    });

    $("#embed_video_field").bind('keyup', function(e){
      if(e.keyCode == 8) { // backspace
        $(this).val("");
        submitVideo.prop("disabled", true);
      }
    });

    submitVideo.click(function() {
      var embedCode = $("#embed_video_field").val();
      addVideo( embedCode );
      $(this).prop("disabled", true);

      modalObj.close();
    });
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      smallModal: true,
      onClosedEvent: function() {
        $("#embed_video_field").val("");
        $(".embed_video_err").hide();
        Airbo.TileFormModal.openModal();
      }
    });
  }

  function initVars() {
    submitVideo = $(submitVideoSel);
  }

  function initForm() {
    if( $("#tile_builder_form_embed_video").val().length > 0 ) {
      $("#image_uploader").hide();
      toggleVideoSection(true);
    }
    initFormEvents();
  }

  function init() {
    if( modalInitialized ) return;
    modalInitialized = true;

    initVars();
    initModalObj();
    initModalEvents();
    autosize( $("#embed_video_field") );
  }
  return {
   init: init,
   initForm: initForm
  }
}());
