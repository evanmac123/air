var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.SearchTabs = (function(){
  function initTabs(){
    $('.js-search-tab-content').hide();
    $('.js-search-tab-content:first').show();
  }

  function initTabToggle(){
    $('.js-search-tabs li').click(function(){
      $('.js-search-tabs li').removeClass('active');
      $(this).addClass('active');
      var currentTab = $(this).data('tabContent');
      $('.js-search-tab-content').hide();
      $(currentTab).show();
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
