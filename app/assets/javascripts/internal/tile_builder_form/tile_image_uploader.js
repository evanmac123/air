var Airbo = window.Airbo || {};

Airbo.TileImageUploader = (function(){
  var initialized
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
    remoteMediaUrl.change();
  }

  function libraryImageSelected(url, imgWidth, imgHeight, id){
    updateHiddenImageFields();
    setFormFieldsForSelectedImage(url, imgTypeFromFilename(url));
    showImagePreview(url, imgWidth, imgHeight);
  }

  function setFormFieldsForSelectedImage(url, type){
    remoteMediaUrl.val(url);
    remoteMediaType.val(type || "image");
  }

  function updateHiddenImageFields() {
    imageContainer.val('');
    noImage.val('');
  };

  function removeImage(){
    updateHiddenImageFields();
    noImage.val('true');
    notifyImageCleared() 
    remoteMediaUrl.val(undefined);
    remoteMediaUrl.change();
  }

  function notifyImageCleared(){
    $.Topic("image-cleared").publish(); 
  }

  function notifyImageUploaded(imgUrl, imgWidth, imgHeight){
    $.Topic("image-selected").publish({url: imgUrl, h: imgHeight, w: imgWidth});
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

    $.Topic('image-selected').subscribe( function(imgProps){
      setFormFieldsForSelectedImage(imgProps.url);
    });

    initjQueryObjects();
    initClearImage();


    Airbo.DirectToS3ImageUploader.init( {
      processed: notifyImageUploaded,
      done: directUploadCompleted,
    });

    return this;
  }

  return {
    init: init,
    remoteMediaUrl: getRemoteMediaURL,
    removeImage: removeImage,
    setFormFieldsForSelectedImage: setFormFieldsForSelectedImage
  };

}());


