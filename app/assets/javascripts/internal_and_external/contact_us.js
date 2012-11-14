$(function() {
  $('.contact_us_link').click(function(e){
    e.preventDefault();
    clickWidgetWhenVisible()
  });
});


function clickWidgetWhenVisible(){
  var widget = $('#IntercomDefaultWidget');
  if (widget.length > 0){
    //console.log('found a widget');
    widget.click();
  }else{
    //console.log('no widget');
    setTimeout(clickWidgetWhenVisible, 100);
  }

}
