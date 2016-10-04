window.moveTileConfirmationModal = function() {

  $(".move-tile-confirm .cancel").click(function(e) {
    e.preventDefault();
    window.moveConfirmationDeferred.reject();
    return $(".move-tile-confirm").foundation('reveal', 'close');
  });


  $(".move-tile-confirm .confirm").click(function(e) {
    e.preventDefault();
    return $(".move-tile-confirm").foundation('reveal', 'close');
  });

  return $(document).on('close.fndtn.reveal', '.move-tile-confirm', function() {
    return window.moveConfirmationDeferred.resolve();
  });
};
