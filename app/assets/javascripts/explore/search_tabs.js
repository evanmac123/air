var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.SearchTabs = (function(){
  function initTabs(){
    $('.js-search-tab-content').hide();
    $('.js-search-tab-content:first').show();
  }

  function initTabToggle(){
    $('.js-search-tabs li').click(function(){
      $(document).scrollTop(0);
      $('.js-search-tabs li').removeClass('active');
      $(this).addClass('active');
      var currentTab = $(this).data('tabContent');
      $('.js-search-tab-content').hide();
      $(currentTab).show();
    });
  }

  function initMoreTabToggle(){
    $('.searchMoreTabLink').click(function(){
      $('.js-my-tiles-tab').trigger("click")
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
