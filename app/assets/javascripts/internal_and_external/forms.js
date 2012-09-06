$(function(){

  $.ajaxSetup({ cache: false });

  $('.with-hint-text').live('focus', (function(e) {
    $(this).attr('value', '').removeClass('with-hint-text');
  }));
});
