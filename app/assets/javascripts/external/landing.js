var Airbo = window.Airbo || {};

Airbo.Landing = (function(){
  function init() {
    $("a.topic").click(function() {
      var name = $(this).text();
      Airbo.Utils.ping("Viewed Priority", {priority: name, source: "Marketing Landing Page"});
    });
  }
  return {
  init: init
}
}());

$(function(){
  // so specific selectors because we have product page with old header
  if( $(".topics_section").length > 0 ){
    Airbo.Landing.init();
  }
});
