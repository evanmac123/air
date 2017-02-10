var Airbo = window.Airbo || {};

Airbo.TileImageUploader = (function(){
  var initialized
    , remoteMediaUrl
    , remoteMediaType

    , remoteMediaUrlSelector = '#remote_media_url'
    , remoteMediaTypeSelector = '#remote_media_type'
  ;

  function imgTypeFromFilename(filename){
    return "image/" + filename.substr(filename.lastIndexOf('.')+1)
  }

  function directUploadCompleted(data,file, filepath){
    setFormFieldsForSelectedImage(filepath, file.type);
    remoteMediaUrl.change();
  }


  function setFormFieldsForSelectedImage(url, type){
    remoteMediaUrl.val(url);
    remoteMediaType.val(type || "image");
  }


  function notifyImageUploaded(imgUrl, imgWidth, imgHeight){
    $.Topic("image-selected").publish({url: imgUrl, h: imgHeight, w: imgWidth});
  }

  function initDom(){
    remoteMediaUrl = $(remoteMediaUrlSelector);
    remoteMediaType = $(remoteMediaTypeSelector);
    initImageSelectedListener();
  }

  function getRemoteMediaURL(){
    return remoteMediaUrl.val();
  }

  function initImageSelectedListener(){
    $.Topic('image-selected').subscribe( function(imgProps){
      setFormFieldsForSelectedImage(imgProps.url);
    });
  }

  function init(libraryModal){

    initDom();

    Airbo.DirectToS3ImageUploader.init( {
      processed: notifyImageUploaded,
      done: directUploadCompleted,
    });

    return this;
  }

  return {
    init: init,
    remoteMediaUrl: getRemoteMediaURL,
    setFormFieldsForSelectedImage: setFormFieldsForSelectedImage
  };

}());


