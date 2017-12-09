function bindCreateNewBoardControls() {
  $('#new_board_creation form').submit(function(event) {
    disableNewBoardCreationButton();
  });

  $('#cancel_board_creation').click(function(event) {
    event.preventDefault();
    $('#new_board_creation').foundation('reveal', 'close');
  });
}
