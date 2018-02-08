var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.StandardModal = (function() {
  return function() {
    var modal;
    var modalSel;
    var modalContainer;
    var modalContent;
    var modalXSel;
    var params;
    var defaultParams = {
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
      modalClass: "",
      closeMessage: function() {
        return "Are you sure";
      }
    };

    function scrollModalToTop() {
      if (params.scrollOnOpen) {
        modal.scrollTop(0);
      }
    }

    function open() {
      modal.foundation("reveal", "open");
      scrollModalToTop();
    }

    function closeModal() {
      var msg = params.closeMessage();
      Airbo.Utils.approve(msg, modal.foundation.bind(modal, "reveal", "close"));
    }

    function close() {
      if (params.closeAlt) {
        params.closeAlt();
      } else if (params.confirmOnClose) {
        closeModal();
      } else {
        modal.foundation("reveal", "close");
      }
    }

    function setContent(content) {
      modal.find(".modal_content").html(content);
    }

    function bodyScrollVisibility(show) {
      var overflow = "";
      var width = "";
      if (!show) {
        overflow = "hidden";
        width = $("body").width();
      }

      $("body").css({ "overflow-y": overflow });
      $("body, header").css("width", width);
    }

    function triggerStickyX() {
      if (params.closeSticky) {
        sizes = $(modalXSel)[0].getBoundingClientRect();
        if (modal.scrollTop() > 50) {
          $(modalXSel)
            .addClass("sticky")
            .css("left", sizes.left);
        } else {
          $(modalXSel)
            .removeClass("sticky")
            .css("left", "");
        }
      }
    }

    function initEvents() {
      modal.bind("open.fndtn.reveal", function() {
        bodyScrollVisibility(false);
        triggerStickyX();
      });

      modal.bind("opened.fndtn.reveal", function(event) {
        if (!$(event.target).hasClass("reveal-modal")) {
          return;
        }
        scrollModalToTop();
        params.onOpenedEvent();
      });

      modal.bind("closed.fndtn.reveal", function() {
        if ($(".reveal-modal.open").length === 0) {
          bodyScrollVisibility(true);
        }
        params.onClosedEvent();
      });

      $(modalXSel).click(function(e) {
        e.preventDefault();
        e.stopPropagation();
        close();
      });

      // stickable closeX
      modal.scroll(function() {
        triggerStickyX();
      });

      $(params.closeSel).click(function(e) {
        e.preventDefault();
        close();
      });

      if (params.closeOnBgClick) {
        [modalSel, modalContainerSel, modalContentSel].forEach(function(el) {
          $("body").on("click", el, function(event) {
            if ($(event.target).is(el)) {
              close();
            }
          });
        });
      }
    }

    function dynamicModal() {
      var modalTemplate =
        params.template || HandlebarsTemplates.standardModal();

      return $(modalTemplate).clone();
    }

    function makeModal() {
      modalId = params.modalId;
      modalSel = "#" + modalId;
      modal = $(modalSel);
      // make ajax modal
      if (params.useAjaxModal && modal.length === 0) {
        modal = dynamicModal();
        modal.appendTo($(".modals"));
        modal.attr("id", modalId);
      }
      modal.addClass(params.modalClass);
      // parts of modal
      modalContainerSel = modalSel + " .modal_container";
      modalContentSel = modalSel + " #modal_content";
      modalXSel = modalSel + " .close-reveal-modal";
      // small modals for some messages etc.
      if (params.smallModal) {
        modal.addClass("standard_small_modal");
      }
      if (params.closeSticky) {
        $(modalXSel).addClass("stickable");
      }
    }

    function setConfirmOnClose(val) {
      params.confirmOnClose = val;
    }

    function init(customParams) {
      params = $.extend(defaultParams, customParams);
      makeModal();
      initEvents();
    }

    return {
      init: init,
      open: open,
      close: close,
      setContent: setContent,
      setConfirmOnClose: setConfirmOnClose
    };
  };
})();
