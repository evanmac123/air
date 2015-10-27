$(function() {
  //Calls the tocify method on your HTML div.
  support = $("#support_tocify");
  if(support.length > 0){
    $("#support_tocify").tocify({context: "#support_content"});
  }
});
