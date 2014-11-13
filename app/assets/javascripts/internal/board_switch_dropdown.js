function bindBoardSwitchDropdownSelect() {
  $('.board_switch_dropdown select').live('change', function(event) {
    selectedOption = $(event.target).find('option:selected');
    boardId = selectedOption.val();
    $('#board-switch-link-' + boardId).click();
  });
}
