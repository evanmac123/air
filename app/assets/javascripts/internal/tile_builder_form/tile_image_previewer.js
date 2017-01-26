
var Airbo = window.Airbo || {};

/************************************************
 *
 * Provides the image preview functionality for
 * both images selected from the library and
 * images that are uploaded by the user
 *
 * **********************************************/


Airbo.TileImagePreviewer = (function(){
  var imageMgr, imgPreview;

  function removeImageCredit() {
    $('.image_credit_view').text('').trigger('keyup').trigger('focusout');
  };

  function clearPreviewImage(){
    showPlaceholder();
    removeImageCredit();
    $("#uploaded_image_file").text("Pick an image").removeClass("file_selected")
  }

  function showPlaceholder() {
    imgPreview.removeClass('show_shadows').addClass('show_placeholder');
  };

  function showShadows() {
    imgPreview.removeClass('show_placeholder').addClass('show_shadows');
  };


  function setPreviewImage(imageUrl, imgWidth, imgHeight) {
    var width = 600
      , fullHeight
    ;

    if(imgWidth && imgHeight){
      fullHeight = parseInt( imgHeight * width / imgWidth );
      imgPreview.addClass("loading").css("height", fullHeight);
    }

    showShadows();
    $('#upload_preview').attr("src", imageUrl);
  };


  function init(mgr){
    $.Topic('image-selected').subscribe( function(imgProps){
      setPreviewImage(imgProps.url, imgProps.w, imgProps.h);
    } );


    $.Topic('image-cleared').subscribe( function(){
      clearPreviewImage();
    });

    imgPreview= $('.image_preview');
    return this;
  }

  return {
    init: init,
    setPreviewImage: setPreviewImage,
    clearPreviewImage: clearPreviewImage
  };

})();
