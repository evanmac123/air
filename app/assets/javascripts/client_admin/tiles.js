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
