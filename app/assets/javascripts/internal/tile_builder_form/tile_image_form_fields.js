var Airbo = window.Airbo || {}

Airbo.TileImageFormFields = (function(){
  var  remoteMediaUrl
    , remoteMediaType
    , mediasource
  ;

  function initDom(){
    remoteMediaUrl = $('#remote_media_url');
    remoteMediaType = $('#remote_media_type');
    mediaSource = $("#media_source");
  }

  function setFormFieldsForSelectedImage(url, type, source){
    remoteMediaUrl.val(url);
    remoteMediaType.val(type || "image");
    mediaSource.val(source);
  }

  function initImageSelectedListener(){
    $.subscribe('image-selected',function(event, imgProps){
      setFormFieldsForSelectedImage(imgProps.url);
    });
  }

  function initImageDoneListener(){
    $.subscribe('image-done',function(event, url, type, source){
      setFormFieldsForSelectedImage(url, type, source)
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

}())
