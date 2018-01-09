var Airbo = window.Airbo || {};

/************************************************
 *
 * Provides the image preview functionality for
 * both images selected from the library and
 * images that are uploaded by the user
 *
 * **********************************************/

Airbo.TileImagePreviewer = (function() {
  var remoteMediaUrlSelector = "#remote_media_url";
  var remoteMediaTypeSelector = "#remote_media_type";
  var clearImageSelector = ".img-menu-item.clear";
  var imagePreviewSelector = ".image_preview";
  var clearImage;

  function removeImageCredit() {
    $(".image_credit_view")
      .text("")
      .trigger("keyup")
      .trigger("focusout");
  }

  function setPreviewImage(imageUrl, imgWidth, imgHeight) {
    $("#upload_preview").attr("src", imageUrl);
    $(imagePreviewSelector).addClass("present");
    $("#tile_form_modal").animate({ scrollTop: 0 }, "fast");
  }

  function removeImage() {
    var missingImage = $("#upload_preview").data("missingTilePreviewImage");
    $("#upload_preview").attr("src", missingImage);

    $(imagePreviewSelector).removeClass("present");
    removeImageCredit();
    remoteMediaUrl.val("");
    remoteMediaUrl.change();
  }

  function initDom() {
    clearImage = $(clearImageSelector);
    remoteMediaUrl = $(remoteMediaUrlSelector);
    remoteMediaType = $(remoteMediaTypeSelector);
    initExpand();
  }

  function initClearImage() {
    clearImage.click(function(event) {
      removeImage();
      event.stopPropagation();
    });
  }

  function initExpand() {
    $(".img-menu-item .fa-compress").hide();

    $(".img-menu-item .fa-expand").click(function() {
      $(".image_preview").removeClass("limited-height");
      $(this).hide();
      $(".img-menu-item .fa-compress").show();
    });

    $(".img-menu-item .fa-compress").click(function() {
      $(".image_preview").addClass("limited-height");
      $(".img-menu-item .fa-expand").show();
      $(this).hide();
    });
  }

  function initImageSelectedListener() {
    Airbo.PubSub.subscribe("image-selected", function(event, imgProps) {
      setPreviewImage(imgProps.url, imgProps.w, imgProps.h);
    });
  }

  function initGifSearchToggle() {
    $(".img-menu-item.gif").on("click", function(e) {
      e.preventDefault();
      var self = $(this);

      if (self.hasClass("active")) {
        self.removeClass("active");
        document.querySelector(".search-input").placeholder = "Search images";
        Airbo.ImageSearcher.setDefaultImageProvider();
      } else {
        self.addClass("active");
        document.querySelector(".search-input").placeholder = "Search GIFs";
        Airbo.ImageSearcher.setImageProvider("giphy");
      }

      if ($(".search-input").val().length > 0) {
        Airbo.ImageSearcher.executeSearch();
      }
    });
  }

  function init(mgr) {
    initDom();
    initClearImage();
    initImageSelectedListener();
    initGifSearchToggle();

    $(".menu-tooltip").tooltipster({ theme: "tooltipster-shadow" });

    return this;
  }

  return {
    init: init
  };
})();
