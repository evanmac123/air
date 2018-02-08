var Airbo = window.Airbo || {};

Airbo.Cheer = (function() {
  function init() {
    $("#cheer_form").submit(function(e) {
      e.preventDefault();
      var form = $(this);
      $.post(form.attr("action"), form.serialize());

      $(".cheer").text($("#cheer_body").val());
      form.hide();
      $(".cheer-posted").show();
    });
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".cheers-component").length > 0) {
    Airbo.Cheer.init();
  }
});
