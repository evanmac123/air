//= require ./ajax-response-handler
//= require ../../../vendor/assets/javascripts/pace.min
//= require jquery
//= require jquery.effects.highlight
//= require jquery_ujs
//= require mobvious-rails
//= require introjs
//= require_tree ../../../vendor/assets/javascripts/external/
//= require_tree ../../../vendor/assets/javascripts/internal/.
//= require ../../../vendor/assets/javascripts/confirm_with_reveal.modified
//= require_self
//= require_tree ./internal
//= require_tree ./internal_and_external/.
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery.ui.autocomplete
//= require ../../../vendor/assets/javascripts/client_admin/jquery.slider.min.js
//= require  medium-editor.min

$(document).ready(function() {
  $('.settings-edit').foundation();
});
$(document).foundation();
$(document).confirmWithReveal(Airbo.Utils.confirmWithRevealConfig);

if(undefined) {undefined};
