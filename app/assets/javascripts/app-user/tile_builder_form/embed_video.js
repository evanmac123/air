var Airbo = window.Airbo || {};
Airbo.EmbedVideo = (function() {
  var timer;

  function addVideo(embedCode) {
    $(".video_frame_block").html(embedCode);
    $("#remote_media_url").val("/assets/video.png");
    $("#media_source").val("video-upload");
    timer = waitForVideoLoad();
    $(".video_frame_block iframe").on("load", function(event) {
      clearTimeout(timer);
      Airbo.PubSub.publish("video-added");
    });
  }

  function waitForVideoLoad() {
    return setTimeout(raiseUnloadableError, 5000);
  }

  function raiseUnloadableError() {
    Airbo.PubSub.publish("video-load-error");
  }

  function raiseUnparsableError() {
    Airbo.PubSub.publish("video-link-parse-error");
  }

  function removeVideo() {
    $("#remote_media_url").val("");
    $("#tile_embed_video").val("");
    $(".video_frame_block").html("");

    var missingImage = $("#upload_preview").data("missingTilePreviewImage");
    $("#upload_preview").attr("src", missingImage);

    Airbo.PubSub.publish("video-removed");
  }

  function getValidCode(text) {
    try {
      text =
        $(text)
          .filter("iframe")
          .prop("outerHTML") ||
        $(text)
          .find("iframe")
          .prop("outerHTML");
      return text;
    } catch (e) {
      return undefined;
    }
  }

  function initPaste() {
    $("body").on("input", "#tile_embed_video", function(event) {
      var val = $(this).val();
      Airbo.PubSub.publish("video-link-entered");
      if (val !== "") {
        code = getValidCode(val);

        if (code == undefined) {
          raiseUnparsableError();
        } else {
          addVideo(code);
        }
      }
    });
  }

  function initClearCode() {
    $("body").on("keyup", "#tile_embed_video", function(e) {
      if (e.keyCode == 8) {
        $(this).val("");
        Airbo.PubSub.publish("video-link-cleared");
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

  function initDom() {
    initPaste();
    initClearCode();
    initClearVideo();
  }

  function init() {
    initDom();
  }
  return {
    init: init
  };
})();
