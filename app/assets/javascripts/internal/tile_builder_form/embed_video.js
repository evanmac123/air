var Airbo = window.Airbo || {};

Airbo.EmbedVideo = (function() {
  var modalObj = Airbo.Utils.StandardModal()
    , modalId = "embed_video_modal"
    , submitVideoSel = "#submit_embed_video"
    , submitVideo
  ;
  function addVideoImage() {
    var videoImage = $("#remote_media_url").data("video-image");
    $("#remote_media_url").val(videoImage);
  }
  function removeVideoImage() {
    Airbo.TileImagesMgr.removeImage(); // image with video icon
  }
  function addVideo(embedCode) {
    if( $(embedCode).prop("tagName") != "IFRAME" ) return;

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
  function initEvents() {
    $("#tile_builder_form_embed_video").on("keyup paste", function() {
      addVideo( $(this).val() );
    });
    $(".clear_video").click(function() {
      removeVideo();
    });
    $(".video_placeholder").click(function() {
      modalObj.open();
    });
    $("#embed_video_field").on("keyup paste", function() {
      var validFormat =  $( $(this).val() ).prop("tagName") != "IFRAME"
      submitVideo.prop("disabled", validFormat);
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
  function init() {
    initVars();
    if( $("#tile_builder_form_embed_video").val().length > 0 ) {
      $("#image_uploader").hide();
      $(".video_section").show();
    }
    initEvents();
    autosize($('#tile_builder_form_embed_video'));
    initModalObj();
  }
  return {
   init: init
  }
}());
