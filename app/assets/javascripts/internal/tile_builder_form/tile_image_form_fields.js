var Airbo = window.Airbo || {};

Airbo.TileImageFormFields = (function(){
  var  remoteMediaUrl;
  var  remoteMediaType;
  var  mediasource;

  function initDom(){
    remoteMediaUrl = $('#remote_media_url');
    remoteMediaType = $('#remote_media_type');
    mediaSource = $("#media_source");
  }

  function setFormFieldsForSelectedImage(formFieldArgs) {
    if (remoteUploadComplete(formFieldArgs.url)) {
      remoteMediaUrl.val(formFieldArgs.url);
      remoteMediaType.val(formFieldArgs.type || "image");
      mediaSource.val(formFieldArgs.source);
    }
  }

  function remoteUploadComplete(url) {
    // Confirm direct uploads have valid urls and are no longer base64 encoded images.
    var validUrlRegexp = /(http|https):/;
    return validUrlRegexp.test(url);
  }

  function initImageSelectedListener() {
    Airbo.PubSub.subscribe('image-selected', function(event, formFieldArgs) {
      setFormFieldsForSelectedImage(formFieldArgs);
    });
  }

  function initImageDoneListener(){
    Airbo.PubSub.subscribe('image-done', function(event, formFieldArgs){
      setFormFieldsForSelectedImage(formFieldArgs);
      remoteMediaUrl.change();
    });
  }

  function init(){
    initDom();
    initImageSelectedListener();
    initImageDoneListener();
  }

  return {
    init: init
  };

}());
