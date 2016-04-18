//= require mobvious-rails
//= require_tree ./client_admin
//= require ./ajax-response-handler
//= require_tree ../../../vendor/assets/javascripts/external/

//= require highcharts/highcharts
//= require highcharts/modules/exporting
//= require ../../../vendor/assets/javascripts/client_admin/jquery.slider.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.payment
//= require ../../../vendor/assets/javascripts/client_admin/jquery-dialog.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery-sortable.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.ui.touch-punch.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.scrollTo.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.form.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.jscroll
//= require ../../../vendor/assets/javascripts/confirm_with_reveal.modified

//= require ../../../vendor/assets/javascripts/internal/jquery.jpanelmenu.min
//= require ../../../vendor/assets/javascripts/internal/jRespond.min
//= require slick-carousel/slick/slick

//= require ./internal_and_external/underscore-min
//= require ./internal/tile_preview/tile_answers
//= require ./internal/show_more_tiles_link
//= require ./internal/countUp.min
//= require ./internal/byte_counter
//= require internal/flashes
//= require internal_and_external/nerf_links_with_login_modal
//= require wice_grid
//= require ../../../vendor/assets/javascripts/external/foundation.min
//= require history_jquery
//= require internal/create_new_board
//= require internal/validate_new_board
//= require ../../../vendor/assets/javascripts/intro.min
//= require jquery.tooltipster.min
//= require ./external/placeholder_ie.js
//= require internal/offcanvas_menu
//= require internal/board_switch_dropdown
//= require internal_and_external/intercom_setup
//= require internal_and_external/contact_airbo
//= require internal/preflight
//= require_tree ./internal/tile_builder_form/
//= require_tree ./internal/tile_manager/
//= require internal/byte_counter
//= require_tree ./vendor_customization

var Airbo = window.Airbo || {};

$(document).ready(function() {
  $('.client_admin-users, .client_admins-show').foundation();
});
$(document).foundation();
$(document).foundation('reveal', {animation: "none"});

$(document).confirmWithReveal(Airbo.Utils.confirmWithRevealConfig);
