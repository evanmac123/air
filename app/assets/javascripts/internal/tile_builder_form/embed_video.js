var Airbo = window.Airbo || {};

Airbo.EmbedVideo = (function() {
  var modalObj = Airbo.Utils.StandardModal()
    , modalId = "embed_video_modal"
    , submitVideoSel = "#submit_embed_video"
    , submitVideo
    , modalInitialized = false
  ;
  function addVideoImage() {
    var videoImage = $("#remote_media_url").data("video-image");
    $("#remote_media_url").val(videoImage);
  }
  function removeVideoImage() {
    Airbo.TileImagesMgr.removeImage(); // image with video icon
  }
  function addVideo(embedCode) {
    $("#image_uploader").hide();
    $(".video_section").show();
    $(".video_frame_block").html(embedCode);
    addVideoImage();

    $("#tile_builder_form_embed_video").val(embedCode);
  }
  function removeVideo() {
    removeVideoImage();
    $("#image_uploader").show();
    $(".video_section").hide();
    $(".video_frame_block").html("");
    $("#tile_builder_form_embed_video").val("");
  }
  function initFormEvents() {
    // form events
    $(".clear_video").click(function() {
      removeVideo();
    });
    $(".video_placeholder").click(function() {
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
    submitVideo.click(function() {
      var embedCode = $("#embed_video_field").val();
      addVideo( embedCode );

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
      $(".video_section").show();
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
