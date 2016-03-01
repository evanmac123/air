var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.FakeModal = (function(){
  return function(){
    var defaultParams = {
          containerSel: ".content",
          onOpenedEvent: Airbo.Utils.noop
        }
      , params
    ;
    function open() {
      params.onOpenedEvent();
    }
    function close() {

    }
    function setContent(content) {
      $(params.containerSel).html(content);
    }
    function init(userParams) {
      params = $.extend(defaultParams, userParams);
    }
    return {
     init: init,
     open: open,
     close: close,
     setContent: setContent
    }
  }
}());