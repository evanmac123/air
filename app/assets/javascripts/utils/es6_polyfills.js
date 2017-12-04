var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.ES6Polyfills = (function(){

  function init(){

    if (!String.prototype.includes) {
      String.prototype.includes = function(search, start) {
        'use strict';
        if (typeof start !== 'number') {
          start = 0;
        }

        if (start + search.length > this.length) {
          return false;
        } else {
          return this.indexOf(search, start) !== -1;
        }
      };
    }
  }

  return {
    init: init
  };

}());

Airbo.Utils.ES6Polyfills.init();
