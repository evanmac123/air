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
    function setContent(content) {
      $(modalContentSel).html(content);
    }
    function bodyScrollVisibility(show) {
      overflow = "";
      width = "";
      if(!show) {
        overflow = "hidden";
        width = $("body").width()
      }

      $("body").css({"overflow-y": overflow});
      $("body, header").css("width", width);
    }

    function initEvents() {
      modal.bind('open.fndtn.reveal', function(){
        bodyScrollVisibility(false);
      });

      modal.bind('opened.fndtn.reveal', function(){
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

      // if(fixedX) {
      //
      // }
    }
    function initVars(params) {
      if(params.useAjaxModal) {
        $(".ajax_modal").attr("id", params.modalId);
      }
      modalId = params.modalId;
      modalSel = "#" + modalId;
      modal = $(modalSel);
      modalContainerSel = modalSel + " .modal_container";
      modalContentSel = modalSel + " #modal_content";
      // modalXSel = modalSel + ".close-reveal-modal";
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
     open: open,
     setContent: setContent
    }
  }
}());
