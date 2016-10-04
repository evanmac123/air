window.moveTileConfirmationModal = function() {

  $(".move-tile-confirm .cancel").click(function(e) {
    e.preventDefault();
    window.moveConfirmationDeferred.reject();
    $(".move-tile-confirm").foundation('reveal', 'close');
  });


  $(".move-tile-confirm .confirm").click(function(e) {
    e.preventDefault();
    $(".move-tile-confirm").foundation('reveal', 'close');
  });

  $(document).on('close.fndtn.reveal', '.move-tile-confirm', function() {
    window.moveConfirmationDeferred.resolve();
  });
};
