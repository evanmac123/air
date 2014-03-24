$(document).ready(function() {
  $('#tile-manager-tabs, #tile-reports-tabs').tabs();

  $('#tile-joyride').foundation('joyride', 'start', {
      nextButton: false,
      tipLocation: 'left',
      template : { // HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide tile"><span class="joyride-nub"></span></div>'
      }
    });
    
  $('#tile-joyride-index-post').foundation('joyride', 'start', {
      tipLocation: 'top',
      postStepCallback     : function (){
          $.ajax("/client_admin/tiles/active_tile_guide_displayed");
      },
      template : { // HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide tile-index-post"><span class="joyride-nub"></span></div>'
      }
    });
        
  $('#tile-joyride-index-main-menu').foundation('joyride', 'start', {
      tipLocation: 'bottom',
      postStepCallback     : function (){
          $('.joyride-tip-guide:last').removeClass("tile-index-share");
          $('.joyride-tip-guide:last').addClass("tile-index-main-menu");
          $.ajax("/client_admin/shares/clicked_got_it_on_first_completion")
      },
      template : { // HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide tile-index-share"><span class="joyride-nub"></span></div>'
      }
    });
    
  $('#tile-joyride-index-posted-tile').foundation('joyride', 'start', {
      tipLocation: 'bottom',
      template : { // HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide tile-index-posted-tile"><span class="joyride-nub"></span></div>'
      }
    });
        
  $('#tile-joyride-show-post').foundation('joyride', 'start', {
      template : { // HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide tile-show-post"><span class="joyride-nub"></span></div>'
      }
    });
    
  $('#tile-joyride-show-archive').foundation('joyride', 'start', {
      nextButton: false,
      template : { // HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide tile-show-archive"><span class="joyride-nub"></span></div>'
      }
    });
});
