function bindOffcanvasMenu(boardSwitchingAllowed) {
  var jPM = $.jPanelMenu({
    menu: 'header nav',
    trigger: '.off-canvas-toggle a'
  });
  var jRes = jRespond([
    {
      label: 'small',
      enter: 0,
      exit: 767
    },{
      label: 'large',
      enter: 768,
      exit: 10000
    }
  ]);
  jRes.addFunc([
    {
      breakpoint: 'small',
      enter: function() {
        window.intercomDisabled = true;
        jPM.on();
        desktop_user_menu().show();
        desktop_admin_menu().show();
      },
      exit: function() {
        jPM.off();
        hideUserMenu();
        hideAdminMenu();
      }
    },{
      breakpoint: 'large',
      enter: function() {
        user_toggler().on();
        admin_toggler().on();
        bindTogglers(boardSwitchingAllowed);
      },
      exit: function() {
        user_toggler().off();
        admin_toggler().off();
        desktop_user_menu().show();
        desktop_admin_menu().show();
      }
    }
  ]);
}
