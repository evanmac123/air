var Airbo = window.Airbo || {};

Airbo.FixedPageSize = (function(){
  function init() {
    // set fixed body width so no shifting occurs for modals
    $("body").css("width", $("body").width());
  }
  return {
    init: init
  };
}());

$(document).ready(function() {
  Airbo.FixedPageSize.init();
});
