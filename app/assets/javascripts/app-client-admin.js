//= require ../../../vendor/assets/javascripts/pace.min
//= require mobvious-rails
//= require_tree ./client_admin
//= require ./ajax-response-handler
//= require_tree ../../../vendor/assets/javascripts/external/

// highcharts.js and exporting.js are both from Highcharts, and the load order matters
//= require ../../../vendor/assets/javascripts/client_admin/highcharts
//= require ../../../vendor/assets/javascripts/client_admin/exporting
//= require ../../../vendor/assets/javascripts/client_admin/jquery.slider.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.payment
//= require ../../../vendor/assets/javascripts/client_admin/jquery-dialog.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery-sortable.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.ui.touch-punch.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.scrollTo.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.form.min
//= require ../../../vendor/assets/javascripts/client_admin/confirm_with_reveal

//= require ../../../vendor/assets/javascripts/internal/jquery.jpanelmenu.min
//= require ../../../vendor/assets/javascripts/internal/jRespond.min

//= require ./internal_and_external/underscore-min
//= require ./internal/tiles
//= require ./internal/show_more_tiles_link
//= require ./internal/countUp.min
//= require ./internal/byte_counter
//= require internal/flashes
//= require internal_and_external/nerf_links_with_login_modal
//= require wice_grid
//= require ../../../vendor/assets/javascripts/external/foundation.min
//= require history_jquery
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require internal/create_new_board
//= require internal/validate_new_board
//= require introjs
//= require jquery.tooltipster.min
//= require ./external/placeholder_ie.js
//= require internal/offcanvas_menu
//= require internal/board_switch_dropdown
//= require internal_and_external/intercom_setup
//= require internal_and_external/contact_airbo
//= require internal/preflight
//= require_tree ./internal/tile_builder_form/
//= require_tree ./internal/tile_manager/
//= require  medium-editor.min
//= require internal/byte_counter
//= require_tree ../../../vendor/assets/javascripts/internal/tile_builder_form

var Airbo = window.Airbo || {};

$(document).ready(function() {
  $('.client_admin-users, .client_admins-show').foundation();
});
$(document).foundation();
$(document).confirmWithReveal();


//FIXME This is only here because jQuery is not required at the top of the
//heirarchy ugh!!!!!!!
//
jQuery.validator.addMethod("maxTextLength", function(value, element, param) {
  function textLength(value){
    var length = 0;
    $(value).each(function(idx, obj){
       length += $(obj).text().length;
    })
    return length;
  }
  return this.optional(element) || textLength(value) <= param;
}, jQuery.validator.format("Character Limit Reached"));
