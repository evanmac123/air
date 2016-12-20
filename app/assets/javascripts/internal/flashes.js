var sendPersistentMessageClosedPing;

sendPersistentMessageClosedPing = function() {
  Airbo.Utils.ping('Saw Persistent Welcome Message', { action: 'Exited message' } );
};

window.bindCloseFlash = function(selector, sendPing) {
  return $(selector).click(function(event) {
    $('#flash').slideUp();
    if (sendPing) {
      return sendPersistentMessageClosedPing();
    }
  });
};
