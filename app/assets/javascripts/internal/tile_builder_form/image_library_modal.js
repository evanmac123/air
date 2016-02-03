var Airbo = window.Airbo || {};

Airbo.ImageLibraryModal = (function(){
  var modalId ="images_modal"
  ;
  var modalObj = Airbo.Utils.StandardModal()
    , tileFormModal
  ;
  function close() {
    modalObj.close();
  }
  function open(url) {
    $.ajax({
      type: "GET",
      dataType: "html",
      url: url,
      success: function(data, status,xhr){
        modalObj.setContent( $(data) );
        modalObj.open();
        Airbo.TileImagesMgr.init(Airbo.ImageLibraryModal);
      },
      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      useAjaxModal: true,
      closeAlt: function() {
        tileFormModal.openModal();
      }
    });
  }
  function init(AirboTileFormModal) {
    tileFormModal = AirboTileFormModal;
    initModalObj();
  }
  return {
    init: init,
    open: open,
    close: close
  };
}());
