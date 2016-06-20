var Airbo = window.Airbo || {}
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.TabWidget = (function(){  
  function initTabs(){
    $('#tabs .tab').hide();
    $('#tabs div.tab:first').show();
    $('#tabs ul li:first a').addClass('selected');
  }

  function initTabToggle(){
    $('#tabs ul li a').click(function(){
      $('#tabs ul li a').removeClass('selected');
      $(this).addClass('selected');
      var currentTab = $(this).attr('href');
      $('#tabs .tab').hide();
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

$(function(){
  Airbo.Utils.TabWidget.init();
})
