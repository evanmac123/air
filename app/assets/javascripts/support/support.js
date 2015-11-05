var Airbo = window.Airbo || {};

Airbo.SupportPages = (function(){
  var menuSel = "#toc"
    , menuWrapperSel = ".tocify-wrapper"
    , navSel = "#nav-button"
    , editorSel = "#support_body_editor";

  function initTocifyMenu(){
    if( menu.length == 0 ) return;

    menu.tocify({context: ".content"});
  }

  function hideNav() {
    menuWrapper.removeClass("open");
    nav.removeClass("open");
  }

  function toggleNav() {
    menuWrapper.toggleClass("open");
    nav.toggleClass("open");
  }

  function initMobileNav(){
    if( nav.length == 0 ) return;

    nav.click(toggleNav);
    $(".page-wrapper, .tocify-item").click(hideNav);
  }

  function initEditor(){
    if( editor.length == 0 ) return;

    params = {
      toolbar: {
        buttons: ['bold', 'italic', 'underline', 'unorderedlist', 'orderedlist', "anchor", 'h1', 'h2', 'h3', 'image']
      }
    }
    Airbo.Utils.mediumEditor.init(params);
  }

  function initVars(){
    menu = $(menuSel);
    nav = $(navSel);
    menuWrapper = $(menuWrapperSel);
    editor = $(editorSel);
  }

  function init(){
    initVars();
    initTocifyMenu();
    initMobileNav();
    initEditor();
  }
  return {
    init: init
  };
}());

$(function(){
  Airbo.SupportPages.init();
});
