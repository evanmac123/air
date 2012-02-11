$(function() {
  $('.follow-btn').click(function(){
    $(this).find('form').submit();
  });
  
  $('.stop-following-btn').click(function(){
    $(this).find('form').submit();
  });
});