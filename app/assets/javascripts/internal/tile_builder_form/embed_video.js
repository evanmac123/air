var Airbo = window.Airbo || {};
//TODO clean this up to remove any deprecated functionality
Airbo.EmbedVideo = (function() {
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

  function addVideo(embedCode) {
    $(".video_frame_block").html(embedCode);
    $("#image_uploader").hide();
    toggleVideoSection(true);
    addVideoImage();
  }

  function removeVideo() {
    $("#image_uploader").show();
    toggleVideoSection(false);
    $(".video_frame_block").html("");
    $("#tile_builder_form_embed_video").val("");
  }

  function initFormEvents() {
    $(".clear_video").click(function() {
      removeVideo();
    });
  }

  function getValidCode(text) {
    text = $(text).filter("iframe").prop('outerHTML') || $(text).find("iframe").prop('outerHTML');
    return text;
  }


  function initPaste(){
    $("body").on('input',"#tile_builder_form_embed_video", function() {
      var code = getValidCode($(this).val());
      if( code == undefined){
        $(".embed_video_err").toggle(true);
      }else{
        addVideo(code);
      }

    });
  }

  function initClear(){
    $("#tile_builder_form_embed_video").bind('keyup', function(e){
      if(e.keyCode == 8) { // backspace
        $(this).val("");
      }
    });
  }


  function initDom(){
    initPaste();
    initClear();
  }

  function initForm() {
    if( $("#tile_builder_form_embed_video").val().length > 0 ) {
      $("#image_uploader").hide();
      toggleVideoSection(true);
    }
    initFormEvents();
  }

  function init() {

    initDom();
    autosize( $("#embed_video_field") );
  }
  return {
   init: init,
   initForm: initForm
  }
}());
