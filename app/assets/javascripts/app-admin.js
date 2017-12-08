// AIM FOR app-admin.js TO BE THE TOP LEVEL IMPORT FILE FORE ALL LEGACY JS (pre move to webpacker)

//= require application
//= require mobvious-rails
//= require tooltipster/tooltipster.bundle.min
//= require jquery.ba-throttle-debounce.min.js
//= require history_jquery

//= require ../../../vendor/assets/javascripts/jquery.jpanelmenu.min
//= require ../../../vendor/assets/javascripts/jquery.form.min

//= require ../../../vendor/assets/javascripts/chosen.jquery.min

//= require ../../../vendor/assets/javascripts/progressbar
//= require_tree ../../../vendor/assets/javascripts/highcharts
//= require vendor_customization/highcharts
//= require ../../../vendor/assets/javascripts/jquery.payment
//= require ../../../vendor/assets/javascripts/jquery.scrollTo.min

//= require ../../../vendor/assets/javascripts/flickity.pkgd.min.js
//= require ../../../vendor/assets/javascripts/intro.min
//= require wice_grid
//= require quill.min.js
//= require_tree ./vendor_customization/quill

//= require_tree ./admin
//= require_tree ./client_admin
//= require_tree ./explore

//= require ./file-uploader
//= require internal_and_external/nerf_links_with_login_modal
//= require internal_and_external/topbar_togglers
//= require internal/create_new_board
//= require internal/validate_new_board
//= require internal/offcanvas_menu
//= require internal/board_switch_dropdown
//= require ./internal/byte_counter

//= require ./internal/tile_preview/tile_answers
//= require ./internal/tile_preview/progress_and_prize_bar
//= require ./internal/tile_preview/user_tile_preview
//= require ./internal/tile_preview/user-tile-share-options
//= require ./internal/show_more_tiles_link
//= require ./internal/countUp.min
//= require ./external/placeholder_ie.js
//= require internal/preflight
//= require_tree ./internal/tile_builder_form/
//= require_tree ./internal/tile_manager/

//= require_tree ./application


var Airbo = window.Airbo || {};

$(document).ready(function() {
  $(document).foundation('reveal', { animation: "none" });
});
