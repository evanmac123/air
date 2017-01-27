
var Airbo = window.Airbo || {};

/************************************************
 *
 * Provides the image preview functionality for
 * both images selected from the library and
 * images that are uploaded by the user
 *
 * **********************************************/


Airbo.TileImagePreviewer = (function(){
  var  remoteMediaUrlSelector = '#remote_media_url'
    , remoteMediaTypeSelector = '#remote_media_type'
    , clearImage
    , clearImageSelector = '.img-menu-item.clear'
  ;


  function removeImageCredit() {
    $('.image_credit_view').text('').trigger('keyup').trigger('focusout');
  };


  function setPreviewImage(imageUrl, imgWidth, imgHeight) {
    $('#upload_preview').attr("src", imageUrl);
  };

  function removeImage(){
    $("#upload_preview").attr("src","/assets/missing-tile-img-full.png") 
    removeImageCredit();
    remoteMediaUrl.val('');
    remoteMediaUrl.change();
  }

  function initDom(){
    clearImage = $(clearImageSelector);
    remoteMediaUrl = $(remoteMediaUrlSelector);
    remoteMediaType = $(remoteMediaTypeSelector);
  }



  function initClearImage(){
    clearImage.click(function(event) {
      removeImage();
      event.stopPropagation();
    });
  }

  function init(mgr){
    initDom();
    initClearImage();

    $.Topic('image-selected').subscribe( function(imgProps){
      setPreviewImage(imgProps.url, imgProps.w, imgProps.h);
    } );

    $('.menu-tooltip').tooltipster();
    return this;
  }

  return {
    init: init,
    setPreviewImage: setPreviewImage,
  };

})();
