//= require ./ajax-response-handler
//= require ../../../vendor/assets/javascripts/pace.min
//= require jquery
//= require jquery.effects.highlight
//= require jquery_ujs
//= require mobvious-rails
//= require ../../../vendor/assets/javascripts/intro.min
//= require_tree ../../../vendor/assets/javascripts/external/
//= require_tree ../../../vendor/assets/javascripts/internal/.
//= require ../../../vendor/assets/javascripts/confirm_with_reveal.modified
//= require_self
//= require_tree ./internal
//= require ./client_admin/tile_preview/tile_carousel
//= require ./client_admin/tile_preview/tile_preview_arrows
//= require ./client_admin/tile_preview/tile_preview_modal
//= require_tree ./internal_and_external/.
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery.ui.autocomplete
//= require ../../../vendor/assets/javascripts/client_admin/jquery.slider.min.js
//= require jquery.tooltipster.min
//= require ./external/schedule_demo
//= require_tree ./vendor_customization

$(document).ready(function() {
  $('.settings-edit').foundation();

  $(document).foundation();
  $(document).foundation('reveal', {animation: "fade"});
  //$(document).confirmWithReveal(Airbo.Utils.confirmWithRevealConfig);
});

if(undefined) {undefined};
