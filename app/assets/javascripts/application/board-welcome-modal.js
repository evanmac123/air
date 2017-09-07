var Airbo = window.Airbo || {};

Airbo.BoardWelcomeModal = (function(){
  var selector = ".js-board-welcome-modal";

  function init() {
    $(".close-airbo-modal").on("click", function() {
      close();
    });
  }

  function open() {
    $(selector).foundation("reveal", "open");
  }

  function close() {
    $(selector).foundation("reveal", "close");
  }

  function showOnLoad() {
    return $(selector).data("showOnLoad") === true;
  }

  return {
    open: open,
    showOnLoad: showOnLoad,
    init: init
  };
}());
