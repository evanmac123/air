var Airbo = window.Airbo || {};

Airbo.TileImageUploader = (function(){
  var initialized
    , previewer
    , noImage
    , imageContainer
    , remoteMediaUrl
    , remoteMediaType
    , clearImage
    , clearImageSelector = '.clear_image'
    , noImageSelector = '#no_image'
    , imageContainerSelector = '#image_container'
    , remoteMediaUrlSelector = '#remote_media_url'
    , remoteMediaTypeSelector = '#remote_media_type'
  ;

  function imgTypeFromFilename(filename){
    return "image/" + filename.substr(filename.lastIndexOf('.')+1)
  }

  function directUploadCompleted(data,file, filepath){
    updateHiddenImageFields();
    setFormFieldsForSelectedImage(filepath, file.type);
  }

  function setFormFieldsForSelectedImage(url, type){
    remoteMediaUrl.val(url);
    remoteMediaType.val(type || "image");
    remoteMediaUrl.change();
  }

  function updateHiddenImageFields() {
    imageContainer.val('');
    noImage.val('');
  };

  function removeImage(){
    updateHiddenImageFields();
    noImage.val('true');
    previewer.clearPreviewImage();
    remoteMediaUrl.val(undefined);
    remoteMediaUrl.change();
  }

  function showImagePreview(imgUrl, imgWidth, imgHeight){
    previewer.setPreviewImage(imgUrl, imgWidth, imgHeight);
    $("#remote_media_url").focusout();
  }

  function showFileName(file){
    previewer.showFileName(file);
  }

  function initClearImage(){
    clearImage.click(function(event) {
      removeImage();
      event.stopPropagation();
    });
  }

  function initjQueryObjects(){
    noImage = $(noImageSelector);
    imageContainer = $(imageContainerSelector);
    remoteMediaUrl = $(remoteMediaUrlSelector);
    remoteMediaType = $(remoteMediaTypeSelector);
    clearImage = $(clearImageSelector);
  }

  function getRemoteMediaURL(){
    return remoteMediaUrl.val();
  }

  function init(libraryModal){
    initjQueryObjects();
    initClearImage();

    previewer = Airbo.TileImagePreviewer.init(this)

    Airbo.DirectToS3ImageUploader.init( {
      processed: showImagePreview,
      done: directUploadCompleted,
      added: showFileName,
    });

    return this;
  }

  return {
    init: init,
    showImagePreview: showImagePreview,
    showFileName: showFileName,
    directUploadCompleted: directUploadCompleted,
    remoteMediaUrl: getRemoteMediaURL,
    removeImage: removeImage
  };

}());


