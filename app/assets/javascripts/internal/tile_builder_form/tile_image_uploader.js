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
    $.Topic("image-done").publish(filepath, file.type, "image-upload");
  }

  function notifyImageUploaded(imgUrl, imgWidth, imgHeight){
   $.Topic("image-selected").publish({url: imgUrl, h: imgHeight, w: imgWidth});
  }


  function init(libraryModal){

    Airbo.DirectToS3ImageUploader.init( {
      processed: notifyImageUploaded,
      done: directUploadCompleted,
    });

    return this;
  }

  return {
    init: init,
  };

}());


