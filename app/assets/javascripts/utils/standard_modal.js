var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.StandardModal = (function(){
  return function(){
    var modal
      , modalSel
      , modalContainer
      , modalContent
      , modalXSel
      , ajaxModalClass = "ajax_modal"
      , ajaxModalSel = "." + ajaxModalClass
      , defaultParams = {
          useAjaxModal: false,
          closeSel: "",
          closeSticky: false,
          onOpenedEvent: Airbo.Utils.noop,
          onClosedEvent: Airbo.Utils.noop,
          closeAlt: null,
          closeOnBgClick: true,
          confirmOnClose: false,
          scrollOnOpen: true,
          smallModal: false,
          modalClass: ""
        }
      , params
    ;
    function scrollModalToTop() {
      if(params.scrollOnOpen) {
        modal.scrollTop(0);
      }
    }
    function open() {
      modal.foundation("reveal", "open");
      scrollModalToTop();
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
      if(params.closeAlt){
        params.closeAlt();
      } else if(params.confirmOnClose){
        closeModal();
      }else{
        modal.foundation("reveal", "close");  
      }
    }
    function setContent(content) {
      modal.find("#modal_content").html(content);
    }
    function bodyScrollVisibility(show) {
      var overflow = "";
      var width = "";
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

      modal.bind('opened.fndtn.reveal', function(event){
        if (!$(event.target).hasClass("reveal-modal")){
          return;
        }
        scrollModalToTop();
        params.onOpenedEvent();
      });

      modal.bind('closed.fndtn.reveal', function(){
        if( $(".reveal-modal.open").length == 0 ) {
          bodyScrollVisibility(true);
        }
        params.onClosedEvent();
      });

      $(modalXSel).click(function(e){
        e.preventDefault();
        e.stopPropagation();
        close();
      });

      // stickable closeX
      if(params.closeSticky) {
        modal.scroll(function() {
          sizes = $(modalXSel)[0].getBoundingClientRect();
          if (modal.scrollTop() > 50) {
            $(modalXSel).addClass('sticky').css("left", sizes.left);
          } else {
            $(modalXSel).removeClass('sticky').css("left", "");
          }
        });
      }

      $(params.closeSel).click(function(e){
        e.preventDefault();
        close();
      });

      if(params.closeOnBgClick) {
        [modalSel, modalContainerSel, modalContentSel].forEach(function(el){
          $("body").on("click", el, function(event){
            if($(event.target).is(el)){
              close();
            }
          });
        });
      }
    }
    function makeModal() {
      modalId = params.modalId;
      modalSel = "#" + modalId;
      modal = $(modalSel);
      // make ajax modal
      if(params.useAjaxModal && modal.length == 0) {
        modal = $(ajaxModalSel).clone();
        modal.removeClass(ajaxModalClass);
        modal.appendTo( $(".modals") );
        modal.attr("id", modalId);
      }
      modal.addClass(params.modalClass);
      // parts of modal
      modalContainerSel = modalSel + " .modal_container";
      modalContentSel = modalSel + " #modal_content";
      modalXSel = modalSel + " .close-reveal-modal";
      // small modals for some messages etc.
      if(params.smallModal) {
        modal.addClass("standard_small_modal")
      }
      if(params.closeSticky) {
        $(modalXSel).addClass("stickable");
      }
    }
    function init(userParams) {
      params = $.extend(defaultParams, userParams);
      makeModal();
      initEvents();
    }
    return {
     init: init,
     open: open,
     close: close,
     setContent: setContent,
     // scrollModalToTop: scrollModalToTop
    }
  }
}());
