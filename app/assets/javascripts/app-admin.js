//= require application
//= require jquery.ui.datepicker
//= require jquery.ui.autocomplete
//= require jquery.ui.tabs
//= require mobvious-rails
//= require ../../../vendor/assets/javascripts/internal/jquery.jpanelmenu.min
//= require ../../../vendor/assets/javascripts/internal/jRespond.min
//= require ../../../vendor/assets/javascripts/client_admin/jquery.form.min
//= require ../../../vendor/assets/javascripts/handlebars.min-latest.js
//= require_tree ../../../vendor/assets/javascripts/admin/.
//= require ./internal_and_external/underscore-min
//= require ./file-uploader
//= require_tree ./admin/.
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
//= require  ../../../vendor/assets/javascripts/jquery.tablesorter.min.js
//= require  ../../../vendor/assets/javascripts/pickadate/picker
//= require  ../../../vendor/assets/javascripts/pickadate/picker.date
//= require  ../../../vendor/assets/javascripts/pickadate/picker.time
//= require ../../../vendor/assets/javascripts/external/foundation.min
//= requre ./admin/contracts
//= require ./admin/demo_search
//= require ./admin/demo_filter
//= require ./admin/lead_contact
//= require ./admin/lead_contact_validations
//= require ./admin/cheer
//= require ./admin/delete_board_modal
//= require ../../../vendor/assets/javascripts/chosen.jquery.min
//= require ../../../vendor/assets/javascripts/external/modernizr
//
$(document).ready(function($) {
  $("#delete-board").on("click", function() {
    Airbo.Utils.Modals.trigger("#delete-board-modal", 'open');
  });

  Airbo.Utils.Modals.bindClose();
});

$(function(){
  //FIXME foundation.min includes foundation.forms js which hijacks forms and
  //hides elements like checkboxes. if we need to use any foundation js then we
  //will need re-display any hijacked form elements
  //$(document).foundation();
  // Airbo.Utils.ES6Polyfills.init();
  Airbo.BoardsAndOrganizationMgr.init();
});
