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

  function initMoreTabToggle(){
    $('.searchMoreTabLink').click(function(){
      $('.searchTabLink').removeClass('selected');
      var newTab = $(this).data('tabId');
      $(newTab).addClass('selected');
      var currentTab = $(this).attr('href');
      $('.searchTab').hide();
      $(document).scrollTop(0);
      $(currentTab).show();
      return false;
    });
  }

  function init(){
    initTabs();
    initTabToggle();
    initMoreTabToggle();
  }

  return {
    init: init
  };
}());
