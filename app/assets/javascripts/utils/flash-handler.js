var Airbo = window.Airbo || {};

Airbo.FlashHandler = (function(){
  function setFlash(xhr){
    var msg = xhr.getResponseHeader('X-Message');
    var type = xhr.getResponseHeader('X-Message-Type');
    showFlash(msg, type);
  }

  function showFlash(msg, type) {
    $('#flash').hide();

    var flash= $(".flash-js");

    flash.find(".flash-content").text(msg);
    flash.find(".flash-js-msg").attr('class', "flash-js-msg " + type);
    flash.slideDown();
    flash.css('overflow','visible');
  }

  return {
    setFlash: setFlash,
    showFlash: showFlash
  };
}());


$(function(){
  $('#close-flash').click(function(event) {
    $('#flash, .flash-js').slideUp();
    $('#flash, .flash-js').css('overflow','visible');
  });
});
