//= require jquery
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require jquery.ui.autocomplete
//= require jquery.ui.tabs
//= require mobvious-rails
//= require ../../../vendor/assets/javascripts/internal/jquery.jpanelmenu.min
//= require ../../../vendor/assets/javascripts/internal/jRespond.min
//= require ./internal_and_external/underscore-min
//= require_tree ../../../vendor/assets/javascripts/admin/.
//= require ./file-uploader
//= require_tree ./admin/.
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require internal_and_external/nerf_links_with_login_modal
//= require internal_and_external/topbar_togglers
//= require internal/create_new_board
//= require internal/validate_new_board
//= require internal/board_settings_controls
//= require internal/flashes
//= require internal/offcanvas_menu
//= require internal/board_switch_dropdown
//= require internal_and_external/intercom_setup
//= require internal/tile_manager/tile_polling
//= require ./internal/byte_counter
//= require  ../../../vendor/assets/javascripts/pickadate/picker
//= require  ../../../vendor/assets/javascripts/pickadate/picker.date
//= require  ../../../vendor/assets/javascripts/pickadate/picker.time

$(function(){
$(".datepicker").pickadate();
})
