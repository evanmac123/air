$(document).ready(function() {
  $('#activity-joyride').foundation('joyride', 'start', {
      template : {// HTML segments for tip layout
        link    : '',
        tip     : '<div class="joyride-tip-guide activity-index"><span class="joyride-nub"></span></div>'
      }
    });
});

window.getStartedLightbox = function(){
  $('#close_get_started_lightbox').click(function(event) {
    $.post("/ping", {event: 'Saw welcome pop-up', properties: {action: "Click 'Get Started'"}});
    event.preventDefault();
    $('#get_started_lightbox').trigger('close');
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
