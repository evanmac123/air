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
    // if( $(embedCode).prop("tagName") != "IFRAME" ) return;

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
    // $("body").on("click", ".clear_video", function() {
    $(".clear_video").click(function() {
      removeVideo();
    });
    // $("body").on("click", ".video_placeholder", function() {
    $(".video_placeholder").click(function() {
      modalObj.open();
    });
  }
  function isIframe(text) {
    return $( text ).prop("tagName") == "IFRAME";
  }
  function getValidCode(text) {
    if( isIframe(text) ){
      return text;
    }
    text = $(text).find("iframe").prop('outerHTML');
    return text;
  }
  function initModalEvents() {
    // modal events
    $("#embed_video_field").on("keyup paste", function() {
      var embedCode =  getValidCode( $(this).val() );
      var blockSubmit = embedCode == undefined;
      if( !blockSubmit ) {
        $(this).val(embedCode);
      }
      submitVideo.prop("disabled", blockSubmit);
    });
    submitVideo.click(function() {
      modalObj.close();

      var embedCode = $("#embed_video_field").val();
      addVideo( embedCode );
      $("#embed_video_field").val("");
    });
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      smallModal: true,
      onClosedEvent: function() {
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
  }
  return {
   init: init,
   initForm: initForm
  }
}());
