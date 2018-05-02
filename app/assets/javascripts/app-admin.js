//= require application

//= require progressbar.js/dist/progressbar.min.js
//= require jquery.payment
//= require jquery.scrollTo.min
//= require wice_grid
//= require quill.min.js
//= require_tree ./vendor_customization/quill
//= require_tree ../../../vendor/assets/javascripts/highcharts
//= require vendor_customization/highcharts

//= require_tree ./app-user
//= require_tree ./app-admin

$(function() {
  $(document).foundation("reveal", { animation: "none" });
});
