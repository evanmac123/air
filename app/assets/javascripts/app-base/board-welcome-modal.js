var Airbo = window.Airbo || {};

Airbo.BoardWelcomeModal = (function(){
  var selector = ".js-board-welcome-modal";

  function init() {
    $(".close-airbo-modal").on("click", function() {
      close();
    });

    $(".js-open-board-welcome-modal").on("click", function(e) {
      e.preventDefault();
      open();
    });

    $(".js-customize-board-cta").on("click", function(e) {
      Airbo.Utils.ping("Public Board Action", { action: "CTA Clicked", copy: $(this).text() });
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
