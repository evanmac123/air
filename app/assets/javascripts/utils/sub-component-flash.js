var Airbo = window.Airbo || {};

Airbo.SubComponentFlash = (function() {
  function insert($lowerNode, message, flashClass) {
    var flashNode = HandlebarsTemplates.flashMessage({
      message: message,
      flashClass: flashClass || "success"
    });

    if ($(".js-sub-component-flash").length > 0) {
      $(".js-sub-component-flash")
        .first()
        .replaceWith(flashNode);
      $(".js-sub-component-flash").show();
    } else {
      $lowerNode.before(flashNode);
      $(".js-sub-component-flash").slideDown();
    }

    initEvents($(flashNode));
  }

  function initEvents($flashNode) {
    $(".js-flash-close").on("click", function(e) {
      e.preventDefault();
      destroy();
    });
  }

  function destroy() {
    $(".js-sub-component-flash").slideUp(400, function() {
      $(".js-sub-component-flash").remove();
    });
  }

  return {
    insert: insert,
    destroy: destroy
  };
})();
