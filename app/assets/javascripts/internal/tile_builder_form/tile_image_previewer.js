
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
    $("#upload_preview").attr("src","/assets/missing-search-image.png") 
    removeImageCredit();
    remoteMediaUrl.val('');
    remoteMediaUrl.change();
  }

  function initDom(){
    clearImage = $(clearImageSelector);
    remoteMediaUrl = $(remoteMediaUrlSelector);
    remoteMediaType = $(remoteMediaTypeSelector);
    initExpand();
  }



  function initClearImage(){
    clearImage.click(function(event) {
      removeImage();
      event.stopPropagation();
    });
  }

  function initExpand(){

    $(".img-menu-item .fa-compress").hide();

    $(".img-menu-item .fa-expand").click(function(){
       $(".image_preview").removeClass("limited-height");
       $(this).hide();
       $(".img-menu-item .fa-compress").show();
    })

    $(".img-menu-item .fa-compress").click(function(){
       $(".image_preview").addClass("limited-height");
       $(".img-menu-item .fa-expand").show();
       $(this).hide();
    })
  }

  function init(mgr){
    initDom();
    initClearImage();


    $.Topic('image-selected').subscribe( function(imgProps){
      setPreviewImage(imgProps.url, imgProps.w, imgProps.h);
    });

    $('.menu-tooltip').tooltipster({theme: 'tooltipster-shadow'});

    return this;
  }

  return {
    init: init,
  };

})();
