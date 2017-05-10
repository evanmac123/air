var Airbo = window.Airbo || {};

Airbo.TileImageUploader = (function() {
  var initialized;
  var remoteMediaUrl;
  var remoteMediaType;
  var remoteMediaUrlSelector = '#remote_media_url';
  var remoteMediaTypeSelector = '#remote_media_type';

  function directUploadCompleted(data, file, filepath) {
    $.publish("image-done", { url: filepath, type: file.type, source: "image-upload" });
  }

  function notifyImageUploaded(imgUrl, imgWidth, imgHeight) {
    $.publish("image-selected", { url: imgUrl, h: imgHeight, w: imgWidth });
  }

  function init(){
    Airbo.DirectToS3ImageUploader.init({
      processed: notifyImageUploaded,
      done: directUploadCompleted
    });

    return this;
  }

  return {
    init: init
  };

}());
