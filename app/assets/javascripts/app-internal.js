//= require jquery
//= require jquery.effects.highlight
//= require jquery_ujs
//= require mobvious-rails
//= require jquery.ba-throttle-debounce.min.js
//= require ../../../vendor/assets/javascripts/intro.min
//= require_tree ../../../vendor/assets/javascripts/external/
//= require_tree ../../../vendor/assets/javascripts/internal/.
//= require ../../../vendor/assets/javascripts/confirm_with_reveal.modified
//= require ../../../vendor/assets/javascripts/client_admin/jquery.form.min
//= require_self
//= require_tree ./internal
//= require ./explore/searches
//= require ./client_admin/tile_preview/image_loading_placeholder
//= require ./client_admin/tile_preview/tile_carousel
//= require ./client_admin/tile_preview/sticky_menu
//= require ./client_admin/tile_preview/tile_preview_arrows
//= require ./client_admin/tile_preview/tile_preview_modal
//= require_tree ./internal_and_external/.
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery.ui.autocomplete
//= require ../../../vendor/assets/javascripts/client_admin/jquery.slider.min.js
//= require ../../../vendor/assets/javascripts/client_admin/jquery.jscroll
//= require tooltipster/tooltipster.bundle.min
//= require ./external/schedule_demo
//= require ./external/request_form

//= require ../../../vendor/assets/javascripts/flickity.pkgd.min.js

$(document).ready(function() {
  $('.settings-edit').foundation();

  $(document).foundation();
  $(document).foundation('reveal', {animation: "fade"});
});
