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

  function setFormFieldsForSelectedImage(fields){
    remoteMediaUrl.val(fields.url);
    remoteMediaType.val(fields.type || "image");
    mediaSource.val(fields.source);
  }

  function initImageSelectedListener(){
    $.subscribe('image-selected', function(event, formFieldArgs) {
      setFormFieldsForSelectedImage(formFieldArgs);
    });
  }

  function initImageDoneListener(){
    $.subscribe('image-done', function(event, formFieldArgs){
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
