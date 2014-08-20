function desktop_board_switch_menu() {
  return $('.other_boards');
}

function desktop_admin_menu() {
  return $('.client_admin_pages');
}
    
function desktop_user_menu() {
  return $('.user_options ul');
}

function board_switch_toggler() {
  return $('#board_switch_toggler');
}

function admin_toggler() {
  return $('#admin_toggle');
}

function user_toggler() {
  return $('#me_toggle');
}


function hideMenu(toggler, menu, beforeHook) {
  if(typeof(beforeHook) === "function") { beforeHook();}
  toggler.removeClass('toggled');
  menu.slideUp('fast');
}

function showMenu(toggler, menu, beforeHook) {
  if(typeof(beforeHook) === "function") { beforeHook();}
  toggler.addClass('toggled');
  menu.slideDown('fast');
}
  
function hideUserMenu() {
  var beforeHook = function(){user_toggler().find('.shadow_overlay').hide()};
  hideMenu(user_toggler(), desktop_user_menu(), beforeHook);
}

function hideAdminMenu() {
  hideMenu(admin_toggler(), desktop_admin_menu());
}

function hideBoards() {
  hideMenu(board_switch_toggler(), desktop_board_switch_menu());
}

function showUserMenu() {
  var beforeHook = function(){user_toggler().find('.shadow_overlay').show()};
  showMenu(user_toggler(), desktop_user_menu());
}

function showAdminMenu() {
  showMenu(admin_toggler(), desktop_admin_menu());
}

function showBoards() {
  showMenu(board_switch_toggler(), desktop_board_switch_menu());
}

function bindTogglers(bindBoardSwitcher) {
  $('html').click(function() {
    if(desktop_user_menu().is(':visible') || desktop_admin_menu().is(':visible') || desktop_board_switch_menu().is(':visible')) {
      hideUserMenu();
      hideAdminMenu();
      hideBoards();
    } else {}
  });
  user_toggler().click(function() {
    if(desktop_admin_menu().is(':visible')) {
      hideAdminMenu();
    } 
    if(desktop_board_switch_menu().is(':visible')) {
      hideBoards();
    }
    if(desktop_user_menu().is(':visible')) {
      hideUserMenu();
    } else {
      showUserMenu();
      return false;
    }
  });
  admin_toggler().click(function() {
    if(desktop_user_menu().is(':visible')) {
      hideUserMenu();
    }
    if(desktop_board_switch_menu().is(':visible')) {
      hideBoards();
    }
    if(desktop_admin_menu().is(':visible')) {
      hideAdminMenu();
    } else {
      showAdminMenu();
      return false;
    }
  });

  if(bindBoardSwitcher) {
    board_switch_toggler().click(function() {
      if(desktop_user_menu().is(':visible')) {
        hideUserMenu();
      }
      if(desktop_admin_menu().is(':visible')) {
        hideAdminMenu();
      }
      if(desktop_board_switch_menu().is(':visible')) {
        hideBoards();
      } else {
        showBoards();
        return false;
      }
    });
  }
}
