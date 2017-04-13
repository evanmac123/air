//= require jquery
//= require jquery_ujs
//= require mobvious-rails
//= require ../../../vendor/assets/javascripts/external/foundation.min
//= require ../../../vendor/assets/javascripts/intro.min
//= require ../../../vendor/assets/javascripts/internal/jquery.jpanelmenu.min
//= require ../../../vendor/assets/javascripts/internal/jRespond.min
//= require_tree ../../../vendor/assets/javascripts/external/
//= require application
//= require ./internal_and_external/underscore-min
//= require internal/flashes
//= require ./external/prefilled_input.js
//= require ./external/marketing_slider.js
//= require ./external/category
//= require ./external/marketing_page_pings
//= require ./external/marketing_page
//= require ./external/signup_requests

$(function(){
  $(document).foundation();
  Airbo.MarketingPagePings.init();
  Airbo.MarketingPage.init();
});
