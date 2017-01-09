var Airbo = {
  init:  function(){

    $.ajaxSetup({
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      }
    });

    this.currentUser = this.Utils.currentUser();

  },

  Utils: {
    userIsSiteAdmin: function(){
     return Airbo.currentUser && Airbo.currentUser.user_type === "site admin";
    },

    userNotSiteAdmin: function(){
      return !(this.userIsSiteAdmin());
    },


    currentUser: function(){
       return $("body").data("current-user");
    },

    supportsFeatureByPresenceOfSelector: function(identifier){
      return $(identifier).length > 0;
    },

    isOldIE: function(){
      if($("html").hasClass("lt-ie9")){
         return true;
      }else {
        return false;
      }
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

      errorClass: "err",
      errorElement: "label",

      errorPlacement: function(error, element) {
        var placement = $(element).data('error');
        if (placement) {
          $(placement).append(error);
        } else {
          error.insertAfter(element);
        }
      },

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
      mixpanel.track(event, properties);
    },

    flash: function(type,msg,config ){
      //TODO make flash duration configurable
      var flash= $(".flash-js");

      flash.find(".flash-content").text(msg);
      flash.find(".flash-js-msg").addClass(type);
      flash.fadeIn(500);
      //TODO small hack to make flash show in specs
      //would normally use native jquery fadeIn(n).fadeOut(n)
      setTimeout(function(){
        flash.fadeOut(0);
      }, 2000);

    },

    

    flashMsg: function (xhr, defaultMsg){
      return xhr.getResponseHeader("X-Message") || defaultMsg;
    },

    truncate: function(text, len){
      var max = (len || 30) - 3;
      return text.length > max ?  text.substring(0, max) + '...' : text;
    },


    initChosen: function(opts){
      var config = $.extend({}, {selector: ".airbo-chosen-select" }, opts);
      $(config.selector).chosen(config);
    },

    Dates: {
      firstDayOfWeek: function(d){

        var curr = d || new Date()
          , dayOfmonth = curr.getDate()
          , dayOfWeek = curr.getDay()
          , adjustment = dayOfmonth - dayOfWeek
          , firstday = new Date(curr.setDate(adjustment +1)) 
        ;
        return firstday;
      },

      lastDayOfWeek: function (d){
        var curr = d || new Date()
          , dayOfmonth = curr.getDate()
          , dayOfWeek = curr.getDay()
          , adjustment = dayOfmonth - dayOfWeek
          , lastday = new Date(curr.setDate(adjustment +7))
        ;
        return lastday;
      },

      firstDayOfMonth:  function(d){
        var curr = d || new Date()
          , year = curr.getFullYear()
          , month = curr.getMonth()
          , firstDay = new Date(year, month , 1)
        ;
        return firstDay;
      },

      lastDayOfMonth:  function(d){
        var curr = d || new Date()
          , year = curr.getFullYear()
          , month = curr.getMonth()
          , firstDay = new Date(year, month , 1)
          , lastDay = new Date(year, month + 1, 0)
        ;
        return lastDay;

      }
    }
  }

};
