var Airbo = window.Airbo || {}

Airbo.LocalStorage = (function(){

  function set(key, value){
    localStorage.setItem(key, JSON.stringify(value));
  }

  function get(key){
    var value = localStorage.getItem(key);
    try{
      return JSON.parse(value);
    }
    catch(e){
      //if item is not parsable as JSON (i.e. string type)
      return value;
    }
  }

  return {
    get: get,
    set: set
  }

}());
