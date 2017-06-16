$(function(){
  if (Airbo.Utils.nodePresent(".dropdown-button-component")) {
    $(".dropdown-button-component").niceSelect();
    $(".dropdown-button-component-init").removeClass("dropdown-button-component-init");
  }
});
