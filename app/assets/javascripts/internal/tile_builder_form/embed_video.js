var Airbo = window.Airbo || {};

Airbo.EmbedVideo = (function() {
  function initEvents() {
    $("#tile_builder_form_embed_video").on("keyup paste", function() {
      $("#image_uploader").hide();

      var embedCode = $(this).val();
      $(".video_section").show().html(embedCode);

      var videoImage = $("#remote_media_url").data("video-image");
      $("#remote_media_url").val(videoImage);
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
