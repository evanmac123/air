
// Any link with the class 'contact_us_link', when clicked, will load the assistly widget, as long as 
// you rendered the assistly-widget in your page
$(function() {
  //loadContactUsModal();
  $('.contact_us_link').click(function(){
    $('.assistly-widget a').click();
    //setTimeout('updateAssistlyDesc()', 1000);
  });
});

function updateAssistlyDesc(){
  $('.customer_widget .inside_desc').text('H Engage Email Support');
}
