var Airbo = window.Airbo || {};

Airbo.TileImageUploader = (function() {
  var initialized;
  var remoteMediaUrl;
  var remoteMediaType;
  var remoteMediaUrlSelector = '#remote_media_url';
  var remoteMediaTypeSelector = '#remote_media_type';
  var eventPrefix = "/s3/tileImage/upload/";

  var imageUploaderSelector = "#image-uploader"
    , imagePreviewSelector = ".image_preview"

  function directUploadCompleted(data, file, filepath) {
    Airbo.PubSub.publish("image-done", { url: filepath, type: file.type, source: "image-upload" });
  }

  function notifyImageUploaded(imgUrl, imgWidth, imgHeight) {
    Airbo.PubSub.publish("image-selected", { url: imgUrl, h: imgHeight, w: imgWidth });
  }

  function defaultBuiltInPreview(file){
    return file.preview;
  }

  function imagePreview(data){
    var node
      , imagePlaceholder
      , index = data.index || 0
      , file = data.files[index]
    ;

    data.context = $(imageUploaderSelector);
    node = data.context.find(imagePreviewSelector);

    if (defaultBuiltInPreview(file)) {
      //Built-in image preview (scales images)
      node.html(file.preview);
    }else{
      //Manually perform our image preview (no scaling)
      loadImage(file, function (img) {
        notifyImageUploaded(img.toDataURL(), img.width, img.height);
      },{canvas: true} );
    }

    if (file.error) {
      node
      .append('<br>')
      .append($('<span class="text-danger"/>').text(file.error));
    }
  }

  function fileAdded(event, data){
    //no op
  }

  function fileProcessed(event, data){
    data.submit();
    imagePreview(data);
  }

  function fileProgress(event, data){
    var progress;
    if (data.context) {
      progress = parseInt(data.loaded / data.total * 100, 10);
    }
  }

  function fileDone(event, data){
    var content, domain, file, path, to;
    file = data.files[0];
    domain = $("#image-uploader").attr('action');
    path = $("#image-uploader" + ' input[name=key]').val().replace('${filename}', file.name);
    directUploadCompleted(data, file, domain+path);
  }



  function initUploadHandlers(){

    Airbo.PubSub.subscribe(eventPrefix + "added", fileAdded);
    Airbo.PubSub.subscribe(eventPrefix + "processed", fileProcessed);
    Airbo.PubSub.subscribe(eventPrefix + "progress", fileProgress);
    Airbo.PubSub.subscribe(eventPrefix + "done", fileDone);
  }


  function init(){


    initUploadHandlers()
    return this;
  }

  return {
    init: init
  };

}());
