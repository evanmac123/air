//= require_tree ./client_admin

// highcharts.js and exporting.js are both from Highcharts, and the load order matters
//= require ../../../vendor/assets/javascripts/admin/highcharts
//= require ../../../vendor/assets/javascripts/admin/exporting


$(document).ready(function() {
  var more = "More options";
  var less = "Less options";
  var i = 1;
  
  $('#toggle-more-options a').click(function(event) {
    $('.extra-user-info').fadeToggle();
    i++;
    if (i%2 != 0) {
      $(this).html(more);
    }else {
      $(this).html(less);
    }

    event.preventDefault();
  });
});
