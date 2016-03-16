var Airbo = window.Airbo || {};

Airbo.Category = (function(){

  function init() {
    btn = $(".full_main_text");
    // text = $(".main_text");
    desc_section = $(".topic_desc_section");

    btn.click(function(e){
      e.preventDefault();
      desc_section.toggleClass("full_height");
    });
  }
  return {
  init: init
}
}());

$(function(){
  // so specific selectors because we have product page with old header
  if( $(".full_main_text").length > 0 ){
    Airbo.Category.init();
  }
});
