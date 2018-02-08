var Airbo = window.Airbo || {};

Airbo.OutboundLeads = (function() {
  function openTab() {
    $(".tablinks").on("click", function() {
      $(".tablinks").removeClass("active");
      $(this).addClass("active");
      $(".tabcontent").hide();
      $("#" + $(this).data("target")).show();
    });
  }

  function init() {
    openTab();
    $(".tabcontent").hide();
    $("#myLeads").show();
    $("#my-leads-link").addClass("active");
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".leads-container").length > 0) {
    Airbo.OutboundLeads.init();
  }
});
