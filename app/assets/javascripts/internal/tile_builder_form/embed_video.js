var Airbo = window.Airbo || {};
//TODO clean this up to remove any deprecated functionality
Airbo.EmbedVideo = (function() {
  var timer;

  function addVideo(embedCode) {
    $(".endless_scroll_loading").show();
    $(".video_frame_block").html(embedCode);

    
    $("#remote_media_url").val("/assets/video.png");

    timer = waitForVideoLoad();
    $(".video_frame_block iframe").on("load", function(event){
      hideLoader(); 
      clearTimeout(timer);
      $.Topic("video-added").publish();
    });
  }

  function initHideListener(){
    $.Topic("media-input-hidden").subscribe( function(){
      if($(".unparsable").is(":visible")){
        $("#remote_media_url").val("");
        $("#tile_builder_form_embed_video").val("");
      }
    });
  }

  function hideLoader(){
    $(".endless_scroll_loading").hide();
  }

  function waitForVideoLoad(){
    return setTimeout(showUnloadableError, 5000);
  }

  function showUnloadableError(){
    hideLoader();
    $(".unloadable").show();
  }

  function hideUnloadableError(){
    $(".unloadable").hide();
  }

  function hideErrors(){
    hideLoader();
    hideUnloadableError();
    hideUnparsableError();
  }

  function showUnparsableError(){
    $(".unparsable").show();
  }

  function hideUnparsableError(){
    $(".unparsable").hide();
  }

  function removeVideo() {
    $("#remote_media_url").val("");
    $("#tile_builder_form_embed_video").val("");
    $(".video_frame_block").html("");
    $("#upload_preview").attr("src","/assets/missing-tile-img-full.png") 
    hideErrors();
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

      if(val !== "" ){
        code = getValidCode(val)

        if(code == undefined){
          showUnparsableError();
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
        hideErrors();
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
    initHideListener();
  }


  function init() {
    initDom();
  }
  return {
   init: init,
  }
}());
