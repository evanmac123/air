var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.PluginExtentions = (function(){

  function forJQueryValidator(){

    function addMaxTextLength(){
      $.validator.addMethod("maxTextLength", function(value, element, param) {

        function textLength(value){
          var length = 0, content= $("<div></div>");
          content.html(value).each(function(idx, obj){
            length += $(obj).text().length;
          })

          return length;
        }
        return this.optional(element) || textLength(value) <= param;
      }, jQuery.validator.format("Character Limit Reached"));
    }

    /* --------INVOKE INDIVIDUAL VALIDATOR EXTENSIONS HERE---------------*/
    addMaxTextLength();

  }

  function init(){
    forJQueryValidator();
  }
 return {
  init: init
 }

}());

$(function(){
  Airbo.Utils.PluginExtentions.init();
});
