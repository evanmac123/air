$(function() {
  $('.follow-btn').click(function(){
    $(this).find('form').submit();
  });
  
  $('.stop-following-btn').click(function(){
    $(this).find('form').submit();
  });
  
  $('.focus_on_search_bar a').click(function(){
    $('#search_string').focus();
  });
});