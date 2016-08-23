//= require jquery
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require ../../../vendor/assets/javascripts/autosize
//= require_tree ./utils

var Airbo = window.Airbo || {};
var DefaultUtils = {

  supportsFeatureByPresenceOfSelector: function(identifier){
    return $(identifier).length > 0;
  },

//FIXME Remove Deprecated PAGes features
  Pages: {
    TILE_BUILDER: "#new_tile_builder_form",
    TILE_STATS_CHART: "#new_tile_stats_chart_form",
    TILE_STATS_GRID: "#tile_stats_grid",
    SURVEY_TABLE: "#survey_table"
  },

  isAtPage: function(identifier){
    return $(identifier).length > 0;
  },

  noop:  function(){},

  urlParamValueByname: function getQueryVariable(variable, target){
    var haystack = target || window.location.search;
    var query = haystack.substring(1);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
      var pair = vars[i].split("=");
      if(pair[0] == variable){
        return pair[1];
      }
    }
    return(false);
  },

  validationConfig: {

    errorPlacement: function(error, element) {
      element.parent().append(error);
    },

    errorClass: "err",

    errorElement: "label",

    highlight: function(element, errorClass, validClass) {
      $(element).addClass("error").removeClass(errorClass);
    },

    unhighlight: function(element, errorClass, validClass) {
      $(element).removeClass("error");
    }
  },

  confirmWithRevealConfig: {
    modal_class: 'tiny confirm-with-reveal destroy_confirm_modal',
    ok_class: 'confirm',
    cancel_class: 'cancel',
    password: false,
    title: "",
    reverse_buttons: true
  },

  htmlDecode: function(input){
    var e = document.createElement('div');
    e.innerHTML = input;
    return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
  },

  ping: function(event, properties) {
    // $.post("/ping", { event: event, properties: properties });
    mixpanel.track(event, properties);
  },

  flash: function(type,msg){
    var flash= $(".flash-js");
    flash.find(".flash-content").text(msg)
    flash.find(".flash-js-msg").addClass(type);
    flash.fadeIn(500);
    //TODO small hack to make flash show in specs
    //would normally use native jquery fadeIn(n).fadeOut(n)
    setTimeout(function(){
      flash.fadeOut(0); 
    }, 1000);
  },

  flashMsg:function (xhr, defaultMsg){
    return xhr.getResponseHeader("X-Message") || defaultMsg;
  },

  truncate: function(text, len){
    var max = (len || 30) - 3;
    return text.length > max ?  text.substring(0, max) + '...' : text;
  }
};


//FIXME add to airbo utils
function isIE11() {
  return !!window.MSInputMethodContext;
}

function isIE() {
  var myNav;
  myNav = navigator.userAgent.toLowerCase();
  if (myNav.indexOf('msie') !== -1) {
    return parseInt(myNav.split('msie')[1]);
  } else if (isIE11()) {
    return 11;
  } else {
    return false;
  }
}


$.extend(Airbo.Utils, DefaultUtils);
