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
      , confirmOnClose
      , modalXSel
      , closeAlt
    ;
    function open() {
      modal.foundation("reveal", "open");
    }
    function closeModal() {
      message = "Are you sure you want to stop editing this tile?" + 
                " Any changes you've made will be lost";
      swal(
        {
          title: "",
          text: message,
          customClass: "airbo",
          animation: false,
          showCancelButton: true
        },

        function(isConfirm){
          if (isConfirm) {
            modal.foundation("reveal", "close");
          }
        }
      );
    }
    function close() {
      if(closeAlt){
        closeAlt();
      } else if(confirmOnClose){
        closeModal();
      }else{
        modal.foundation("reveal", "close");  
      }
    }
    function setContent(content) {
      modal.find("#modal_content").html(content);
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
        if( $(".reveal-modal.open").length == 0 ) {
          bodyScrollVisibility(true);
        }
        onClosedEvent();
      });

      $(modalXSel).click(function(e){
        e.preventDefault();
        e.stopPropagation();
        close();
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
      // if(confirmOnClose) {

      // }
      // if(fixedX) {
      //
      // }
    }
    function initVars(params) {
      modalId = params.modalId;
      modalSel = "#" + modalId;
      if(params.useAjaxModal) {
        modal = $(modalSel);
        if( modal.length == 0 ) {
          modal = $(".ajax_modal").clone();
          modal.removeClass("ajax_modal");
          modal.appendTo( $(".modals") );
          modal.attr("id", params.modalId);
        }
        // $(".ajax_modal").attr("id", params.modalId);
      }
      modal = $(modalSel);
      modalContainerSel = modalSel + " .modal_container";
      modalContentSel = modalSel + " #modal_content";
      modalXSel = modalSel + " .close-reveal-modal";
      closeSel = params.closeSel || "";
      onOpenedEvent = params.onOpenedEvent || Airbo.Utils.noop;
      onClosedEvent = params.onClosedEvent || Airbo.Utils.noop;
      closeAlt = params.closeAlt || null;
      closeOnBgClick = params.closeOnBgClick || true;
      confirmOnClose = params.confirmOnClose || false;
      if(params.smallModal) {
        modal.addClass("standard_small_modal")
      }
      // if(params.modalClass) {
      //   modal.addClass(params.modalClass)
      // }
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
