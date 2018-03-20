var Airbo = window.Airbo || {};

Airbo.BoardMembership = (function() {
  function bindUpdate() {
    $(".js-board-membership-api-update").click(function(e) {
      e.preventDefault();
      update($(this));
    });
  }

  function update($btn) {
    $btn.addClass("with_spinner");
    var $form = $btn.closest("form");

    $.ajax({
      url: $form.attr("action"),
      data: $form.serialize(),
      type: $form.attr("method"),
      success: function(result) {
        $btn.removeClass("with_spinner");
      }
    });
  }

  function init() {
    bindUpdate();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-board-membership")) {
    Airbo.BoardMembership.init();
  }
});
