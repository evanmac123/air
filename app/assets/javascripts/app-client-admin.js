//= require mobvious-rails
//= require_tree ./client_admin
//= require_tree ../../../vendor/assets/javascripts/external/

// highcharts.js and exporting.js are both from Highcharts, and the load order matters
//= require ../../../vendor/assets/javascripts/client_admin/highcharts
//= require ../../../vendor/assets/javascripts/client_admin/exporting
//= require ../../../vendor/assets/javascripts/client_admin/jquery.slider.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.payment

//= require ../../../vendor/assets/javascripts/internal/jquery.jpanelmenu.min
//= require ../../../vendor/assets/javascripts/internal/jRespond.min

//= require ./internal_and_external/underscore-min
//= require ./internal/tiles
//= require ./internal/show_more_tiles_link

//= require wice_grid
//= require ../../../vendor/assets/javascripts/external/foundation.min
//= require history_jquery

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
  
  $('.client_admin-users').foundation();
});
$(document).foundation();
