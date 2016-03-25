$(document).ready(function() {
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
      step : 1,
      postStepCallback : function (){
        $('.joyride-tip-guide:last').removeClass("tile-index-share");
        $('.joyride-tip-guide:last').addClass("tile-index-main-menu");
        if(this.step === 1) {
          $.ajax("/client_admin/tiles/activated_try_your_board");
        } else {
          $.ajax("/client_admin/tiles/clicked_try_your_board_got_it");
        }
        this.step += 1;        
      },
      template : { // HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide tile-index-share"><span class="joyride-nub"></span></div>'
      }
    });
    
  $('#tile-joyride-index-posted-tile').foundation('joyride', 'start', {
      tipLocation: 'bottom',
      postStepCallback: function() {
        $.ajax("/client_admin/tiles/clicked_first_completion_got_it")        
      },
      template : { // HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide tile-index-posted-tile"><span class="joyride-nub"></span></div>'
      }
    });
        
  $('#tile-joyride-show-post').foundation('joyride', 'start', {
      postStepCallback: function() {
        $.ajax("/client_admin/tiles/clicked_post_got_it")
      },
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
