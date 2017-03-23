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
    if(source !=="image-search"){
      remoteMediaUrl.change();
    }
  }

  function initImageSelectedListener(){
    $.subscribe('image-done',function(e, url, type, source){
      setFormFieldsForSelectedImage(url, type, source)
    });
  }

  function init(){
    initDom();
    initImageSelectedListener();
  }

  return {
    init: init
  };

}())
