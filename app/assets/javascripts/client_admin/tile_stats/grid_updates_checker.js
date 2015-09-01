var Airbo = window.Airbo || {};

Airbo.GridUpdatesChecker = (function(){
  var continueRequests = true,
      timeoutID,
      interval = 1000; // 1 second

  function checkForUpdate() {
    console.log(timeoutID);
    if(continueRequests){
      start();
    }
  }

  function start() {
    timeoutID = window.setTimeout(checkForUpdate, interval);
  }

  function stop() {
    if(timeoutID) {
      window.clearTimeout(timeoutID);
    }
  }

  function init() {
    return this;
  }

  return {
    init: init,
    start: start
  };
}());
