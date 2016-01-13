var Airbo = window.Airbo || {};

Airbo.ImageLibrary = (function(){
  var modalId ="images_modal"
  ;
  function getImageLibrary(libaryUrl){
    $.ajax({
      type: "GET",
      dataType: "html",
      url: libaryUrl,
      success: function(data, status,xhr){
        modalObj.setContent( $(data) );
        modalObj.open();
        Airbo.TileImagesMgr.init();
      },
      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }
  function open(libraryUrl) {
    getImageLibrary(libaryUrl);
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      useAjaxModal: true
    });
  }
  function init() {
    initModalObj();
    return this;
  }
  return {
    init: init,
    open: open
  };
}());
