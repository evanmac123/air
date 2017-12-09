//= require jquery
//= require jquery_ujs
//= require mobvious-rails
//= require_tree ../../../vendor/assets/javascripts/external/
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery.ba-throttle-debounce.min.js
//= require jquery.form.min
//= require jquery.jpanelmenu.min
//= require flickity.pkgd.min.js
//= require tooltipster/tooltipster.bundle.min
//= require sweetalert/sweetalert.min
//= require medium-editor.min
//= require chosen.jquery.min
//= require intro.min
//= require autosize
//= require imagesloaded.pkgd.min.js
//= require clipboard.js
//= require jssocials.min.js

// File Uploader
//= require jquery-fileupload/vendor/jquery.ui.widget
//= require jquery-fileupload/vendor/load-image.all.min
//= require jquery-fileupload/vendor/canvas-to-blob
//= require jquery-fileupload/jquery.iframe-transport
//= require jquery-fileupload/jquery.fileupload
//= require jquery-fileupload/jquery.fileupload-process
//= require jquery-fileupload/jquery.fileupload-image
//= require jquery-fileupload/jquery.fileupload-validate
//

//= require handlebars
//= require vendor_customization/handlebars
//= require_tree ./templates

//= require airbo
//= require_tree ./utils
//= require_tree ./application
//= require_tree ./app-user

$(function(){
  Airbo.init();
  $(document).foundation();
});
