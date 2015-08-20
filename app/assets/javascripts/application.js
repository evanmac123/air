var Airbo = window.Airbo || {};
Airbo.Utils = {

  supportsFeatureByPresenceOfSelector: function(identifier){
    return $(identifier).length > 0
  },

}
