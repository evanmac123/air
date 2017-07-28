var Airbo = window.Airbo || {};

Airbo.IntercomEventService = (function(){

  function trackEvent(customEvent, metadata) {
    Intercom('trackEvent', customEvent, metadata);
  }

  return {
    trackEvent: trackEvent
  };

}());

// Intercom event tracking should be inherently temporary -- Used for pings that drive auto messages for a certain period of time.  Try to remember to cleanup after the auto-message is complete.
