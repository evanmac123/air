$(document).ready(function() {
  $('#activity-joyride').foundation('joyride', 'start', {
      template : {// HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide activity-index"><span class="joyride-nub"></span></div>'
      }
    });
});

pingClick = function(action) {
  var slideName = $('#get_started_lightbox').data('slide-name');

  $.post("/ping", {event: 'Saw welcome Pop-Up', properties: {action: action, page: slideName}});
}

closeGetStartedLightbox = function() {
  $('#get_started_lightbox').trigger('close');
}

window.getStartedLightbox = function(){
  function closeWithPing(action) {
    pingClick(action);
    closeGetStartedLightbox();
  }

  $('#lightbox_get_started_button').click(function(event) {
    event.preventDefault();
    closeWithPing("Clicked 'Start'");
  });

  $('#lightbox_close_link').click(function(event) {
    event.preventDefault();
    closeWithPing("Clicked 'Close'");
  });

  $('#get_started_lightbox').lightbox_me({
    onClose: function(){ 
      if( window.showRaffleAfterLightbox == true ){
        showRaffleBox("New Raffle!");
        prizeModalPing("Saw Prize Modal");
      } 
    }
  });
}

window.registerPotentialUserLightbox = function(){
  $('#register_potential_user_lightbox').lightbox_me({closeClick: false});
  $("#potential_user_name").on('input propertychange paste', function() {
    submit_button = $("#register_potential_user_lightbox input[type='submit']")
    if( $(this).val().match(/\w+\s+\w+/) ){
      submit_button.removeAttr("disabled")
    }else{
      submit_button.attr("disabled", "disabled")
    }
    if(!window.enteredName){
      $.post("/ping", {event: 'Saw welcome pop-up', properties: {action: "Entered Name"}})
    }
    window.enteredName = true
  });
}
