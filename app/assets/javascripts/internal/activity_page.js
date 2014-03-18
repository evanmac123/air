$(document).ready(function() {
  $('#activity-joyride').foundation('joyride', 'start', {
      postStepCallback     : function (){
          $.ajax("activity/admin_return_guide_displayed");
      },
      template : {// HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide activity-index"><span class="joyride-nub"></span></div>'
      }
    });
});
