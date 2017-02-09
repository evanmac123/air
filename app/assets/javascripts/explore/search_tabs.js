var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.SearchTabs = (function(){
  function initTabs(){
    $('.searchTab').hide();
    $('.searchTab:first').show();
    $('.searchTabLink:first').addClass('selected');
  }

  function initTabToggle(){
    $('.searchTabLink').click(function(){
      $('.searchTabLink').removeClass('selected');
      $(this).addClass('selected');
      var currentTab = $(this).attr('href');
      $('.searchTab').hide();
      $(currentTab).show();
      return false;
    });
  }

  function init(){
    initTabs();
    initTabToggle();
  }

  return {
    init: init
  };
}());
