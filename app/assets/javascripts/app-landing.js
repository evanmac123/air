//= require jquery
//= require jquery_ujs
//= require mobvious-rails
//= require ./internal_and_external/underscore-min
//= require_tree ../../../vendor/assets/javascripts/external/
//= require ./external/prefilled_input.js
//= require ../../../vendor/assets/javascripts/internal/jquery.jpanelmenu.min
//= require ../../../vendor/assets/javascripts/internal/jRespond.min
//= require ./external/marketing_slider.js
//= require internal/flashes
//= require ../../../vendor/assets/javascripts/external/foundation.min
//= require internal_and_external/intercom_setup
//= require ./external/landing.js
//= require application
//= require ./external/schedule_demo

$(function(){
  $(document).foundation();
  Airbo.ScheduleDemoModal.init();
  Airbo.Utils.TextSelectionDetector.init("#link_for_copy", Airbo.ScheduleDemoModal.linkCopied);
});
