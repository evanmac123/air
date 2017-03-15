var Airbo = window.Airbo || {};
Airbo.EmbedVideo = (function() {
  var timer;

  function addVideo(embedCode) {
    $(".video_frame_block").html(embedCode);
    $("#remote_media_url").val("/assets/video.png");
    $("#media_source").val("video-upload");
    timer = waitForVideoLoad();
    $(".video_frame_block iframe").on("load", function(event){
      clearTimeout(timer);
      $.Topic("video-added").publish();
    });
  }

  function waitForVideoLoad(){
    return setTimeout(raiseUnloadableError, 5000);
  }

  function raiseUnloadableError(){
    $.Topic("video-load-error").publish();
  }

  function raiseUnparsableError(){
    $.Topic("video-link-parse-error").publish();
  }

  function removeVideo() {
    $("#remote_media_url").val("");
    $("#tile_builder_form_embed_video").val("");
    $(".video_frame_block").html("");
    $("#upload_preview").attr("src","/assets/missing-tile-img-full.png");
    $.Topic("video-removed").publish();
  }

  function getValidCode(text) {
    try{
      text = $(text).filter("iframe").prop('outerHTML') || $(text).find("iframe").prop('outerHTML');
      return text;
    }catch(e){
      return undefined;
    }
  }

  function initPaste(){
    $("body").on('input',"#tile_builder_form_embed_video", function(event) {
      var val = $(this).val() ;
      $.Topic("video-link-entered").publish()
      if(val !== "" ){
        code = getValidCode(val)

        if(code == undefined){
          raiseUnparsableError()
        }
        else{
          addVideo(code);
        }
      }
    });
  }

  function initClearCode(){
    $("body").on("keyup", "#tile_builder_form_embed_video", function(e){
      if(e.keyCode == 8) {
        $(this).val("");
        $.Topic("video-link-cleared").publish();
        removeVideo();
        clearTimeout(timer);
      }
    });
  }

  function initClearVideo() {
    $("body").on("click", ".video-menu-item.clear ", function() {
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
