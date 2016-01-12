var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.StandardModal = (function(){
  return function(){
    var modal
      , modalSel
      , closeSel
      , onOpenedEvent
      , onClosedEvent
      , closeOnBgClick
      , modalContainer
      , modalContent
    ;
    function open() {
      modal.foundation("reveal", "open", {
        animation: "fade",
        closeOnBackgroundClick: true,
        bgClass: "fixed_modal_bg"
      });
    }
    function close() {
      modal.foundation("reveal", "close");
    }
    function bodyScrollVisibility(show) {
      value = "";
      if(!show) {
        value = "hidden";
      }
      $("body").css({"overflow-y": value});
    }

    function initEvents() {
      modal.bind('opened.fndtn.reveal', function(){
        bodyScrollVisibility(false);
        onOpenedEvent();
      });

      modal.bind('closed.fndtn.reveal', function(){
        bodyScrollVisibility(true);
        onClosedEvent();
      });

      $(closeSel).click(function(e){
        e.preventDefault();
        close();
      });

      if(closeOnBgClick) {
        [modalSel, modalContainerSel, modalContentSel].forEach(function(el){
          $("body").on("click", el, function(event){
            if($(event.target).is(el)){
              close();
            }
          });
        });
      }
    }
    function initVars(params) {
      modalSel = params.modalSel;
      modal = $(modalSel);
      modalContainerSel = modalSel + " .modal_container";
      modalContentSel = modalSel + " #modal_content";
      closeSel = params.closeSel || "";
      onOpenedEvent = params.onOpenedEvent || Airbo.Utils.noop;
      onClosedEvent = params.onClosedEvent || Airbo.Utils.noop;
      closeOnBgClick = params.closeOnBgClick || true;
    }
    function init(params) {
      initVars(params);
      initEvents();
    }
    return {
     init: init,
     open: open
    }
  }
}());
