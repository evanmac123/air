var Airbo = window.Airbo || {};
Airbo.EmbedVideo = (function() {
  var whitelistedURIs = [
    "www.youtube.com",
    "player.vimeo.com",
    "fast.wistia.net",
    "embed.ted.com",
    "www.kalutra.com"
  ];
  var timer;

  function addVideo(embedCode) {
    $(".video_frame_block").html(embedCode);
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
    removeVideo();
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

  function parseURI(uri) {
    var el = document.createElement("a");
    el.href = uri;
    return el;
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
      var parsedURI = parseURI("" + $(text)[0].attributes["src"].value + "");
      if (whitelistedURIs.indexOf(parsedURI.hostname) > -1) {
        return text;
      } else {
        return "err";
      }
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
          if (code === "err") {
            raiseUnloadableError();
          } else {
            addVideo(code);
          }
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
