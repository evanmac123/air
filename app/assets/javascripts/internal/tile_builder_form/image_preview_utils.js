var Airbo = window.Airbo || {};

function isIE() {
  var myNav;
  myNav = navigator.userAgent.toLowerCase();
  if (myNav.indexOf('msie') !== -1) {
    return parseInt(myNav.split('msie')[1]);
  } else {
    return false;
  }
};

/************************************************
 *
 * Creates a wrapper around the image previewer
 * and the image library modules
 *
 * **********************************************/

Airbo.TileImagesMgr = (function(){
  var initialized,
  previewer, 
  library,
  noImage, 
  imageContainer,
  remoteMediaUrl,
  remoteMediaType;

  function updateHiddenImageFields(caller) {
    imageContainer.val('');
    noImage.val('');

    if (caller === 'imageUploader') {

    } else if (caller === 'clearImage') {
      noImage.val('true');
    } else if (caller === 'imageFromLibrary') {
      library.setSelectedImageId();
    }
  };

  function clearImage(){
    updateHiddenImageFields('clearImage');
    previewer.clearPreviewImage();
    library.clearSelectedImage();
  }

  function showImagePreview(imgUrl){
    previewer.setPreviewImage(imgUrl);
  }

  function initClearImage(){
    $('.clear_image').click(function(event) {
      clearImage()
    });
  }

  function initVars(){
    noImage = $('#no_image'), 
    imageContainer = $('#image_container'),
    remoteMediaUrl = $('#remote_media_url'),
    remoteMediaType = $('#remote_media_type');
  }
  function init(){

    initVars();
    initClearImage();
    previewer = Airbo.ImagePreviewer.init(this)
    library = Airbo.ImageLibrary.init(this)
  }

  return {
    init: init,
    showImagePreview: showImagePreview,
    updateHiddenImageFields: updateHiddenImageFields,
  };

}());


/************************************************
 *
 * Provides the functionality for 
 * interacting with the image library 
 *
 * **********************************************/

Airbo.ImageLibrary = (function(){
  var imageMgr,
      imageFromLibraryField = $("#image_from_library"),
      imageFromLibrarySelector = ".tile_image_block:not(.upload_image)",
      imageFromLibrary=  $(imageFromLibrarySelector);

  function selectedImageFromLibrary() {
    return imageFromLibrary.filter(".selected");
  }
 
  function setSelectedState(imageBlock) {
    imageFromLibrary.removeClass('selected');
    imageBlock.addClass('selected');
  }

  function clearSelectedImage(){
    imageFromLibraryField.val('');
  }

  function setSelectedImageId(){
    imageFromLibraryField.val(selectedImageFromLibrary().data('tile-image-id'));
  }

  function select(imageBlock) {
    imageMgr.showImagePreview(imageBlock.data('image-url'));
    imageMgr.updateHiddenImageFields('imageFromLibrary');
    setSelectedState(imageBlock);
  };

  function selectImageFromLibrary() {
    var id = parseInt(imageFromLibraryField.val());
    if (selectedImageFromLibrary().length === 0 && id > 0) {
       setSelectedState(imageFromLibrary.filter("[data-tile-image-id=" + id + "]"));
    }
  };

  function initImageChooser(){
    $("body").on("click", imageFromLibrarySelector, function() {
      select($(this));
    });
  }

  function init(mgr){
    imageMgr = mgr;
    initImageChooser();
    return this;
  };

  return {
    setSelectedImageId: setSelectedImageId,
    clearSelectedImage: clearSelectedImage,
    init: init
  }
}());


/************************************************
 *
 * Provides the image preview functionality for 
 * both images selected from the library and 
 * images that are uploaded by the user
 *
 * **********************************************/

Airbo.ImagePreviewer = (function(){
  var imageMgr;

  function clearPreviewImage(){
    showPlaceholder();
    removeImageCredit();
  }

  function showPlaceholder() {
    $('.image_preview').removeClass('show_shadows').addClass('show_placeholder');
  };

  function removeImageCredit() {
     $('.image_credit_view').text('').trigger('keyup').trigger('focusout');
  };

  function showShadows() {
     $('.image_preview').removeClass('show_placeholder').addClass('show_shadows');
  };

  function setPreviewImage(imageUrl) {
    showPlaceholder();
    showShadows();
    $('#upload_preview').attr("src", imageUrl);
  };

  function init(mgr){
    imageMgr = mgr
    return this;
  }

  return {
    init: init,
    setPreviewImage: setPreviewImage,
    clearPreviewImage: clearPreviewImage 
  };

})();

$(function() {
  //TODO consider not instantiating Airbo.ImagePreviewer and Airb.ImageLibrary
  //unless neeed
  Airbo.TileImagesMgr.init();
});
