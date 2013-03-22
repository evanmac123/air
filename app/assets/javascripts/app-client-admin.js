//= require_tree ./client_admin
$(document).ready(function() {
  var more = "More options";
  var less = "Less options";
  var i = 1;
  
  $('#toggle-more-options a').click(function(event) {
    $('#user-characteristics').fadeToggle();
    i++;
    if (i%2 != 0) {
      $(this).html(more);
    }else {
      $(this).html(less);
    }

    event.preventDefault();
  });
});
