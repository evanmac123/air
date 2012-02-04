
// Any link with the class 'contact_us_link', when clicked, will load the assistly widget, as long as 
// you rendered the assistly-widget in your page
$(function() {
  //loadContactUsModal();
  $('.contact_us_link').click(function(){
    $('.assistly-widget a').click();
  });
});


