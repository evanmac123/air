$(document).ready(function() {
  $('#activity-joyride').foundation('joyride', 'start', {
      template : {// HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide activity-index"><span class="joyride-nub"></span></div>'
      }
    });
});
