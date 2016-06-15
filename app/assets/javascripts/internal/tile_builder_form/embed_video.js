var Airbo = window.Airbo || {};

Airbo.EmbedVideo = (function() {
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
  }
  function init() {
    if( $("#tile_builder_form_embed_video").val().length > 0 ) {
      $("#image_uploader").hide();
      $(".video_section").show();
    }
    initEvents();
    autosize($('#tile_builder_form_embed_video'));
  }
  return {
   init: init
  }
}());
