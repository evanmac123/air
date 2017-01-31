var Airbo = window.Airbo || {};
//TODO clean this up to remove any deprecated functionality
Airbo.EmbedVideo = (function() {

  function addVideo(embedCode) {
    //var videoImage = $("#remote_media_url").data("video-image");
    //$("#remote_media_url").val(videoImage);
    $(".video_frame_block").html(embedCode);
    $.Topic("video-added").publish();
  }

  function removeVideo() {
    $(".video_frame_block").html("");
    $("#remote_media_url").val("");
    $("#tile_builder_form_embed_video").val("");
    $.Topic("video-removed").publish();
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

  function initClearCode(){
    $("#tile_builder_form_embed_video").bind('keyup', function(e){
      if(e.keyCode == 8) { // backspace
        $(this).val("");
      }
    });
  }

  function initClearVideo() {
    $("body").on("click", ".clear_video", function() {
      removeVideo();
    });
  }



  function initDom(){
    initPaste();
    initClearCode();
    initClearVideo();
  }


  function init() {
    initDom();
  }
  return {
   init: init,
  }
}());
