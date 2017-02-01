var Airbo = window.Airbo || {};
//TODO clean this up to remove any deprecated functionality
Airbo.EmbedVideo = (function() {
  var timer;

  function addVideo(embedCode) {
    $(".video_frame_block").html(embedCode);
    timer = waitForVideoLoad();
    $(".video_frame_block iframe").on("load", function(){
      clearTimeout(timer);
      $.Topic("video-added").publish();
    });
  }

  function waitForVideoLoad(){
    return setTimeout(showError, 5000);
  }

  function showError(){
    $(".video_url_error").show();
  }

  function hideError(){
    $(".video_url_error").hide();
  }

  function removeVideo() {
    $(".video_frame_block").html("");
    $("#remote_media_url").val("");
    $("#tile_builder_form_embed_video").val("");
    $("#upload_preview").attr("src","/assets/missing-tile-img-full.png") 
    $.Topic("video-removed").publish();
  }

  function getValidCode(text) {
    text = $(text).filter("iframe").prop('outerHTML') || $(text).find("iframe").prop('outerHTML');
    return text;
  }

  function initPaste(){
    $("body").on('input',"#tile_builder_form_embed_video", function(event) {
      var val = $(this).val() ;

      if(val !== "" ){
        code = getValidCode(val)

        if(code == undefined){
          $(".embed_video_err").toggle(true);
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
        removeVideo();
        hideError();
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
