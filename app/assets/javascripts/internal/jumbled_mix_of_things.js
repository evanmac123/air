$(function() {
  
  $("#command_central").click(function(){
    $('.bubbly').hide();
  });
  
  if (document.getElementById('command_central')){
    $('#command_central').focus();
    var sugg = "Enter a keyword";
    $('#command_central').val(sugg);
    $('#command_central').click(function(){
      $('#command_central').val('');   
    });
    
    $('#command_central').keypress(function(key){
      if (sugg == $('#command_central').val()){
        $('#command_central').val('');
      }
      if (key.keyCode == 13){
       $('#flash_failure').hide();
      }
      $('#command_central').addClass('green');
      
    })
  };


  launchTutorialIntroduction();
  
  $('#show_tutorial').click(function(){
    showTutorial();
  });
  
  $('#add-new-user').live('click', function() {
    $('#new_user').parent('.hidden-form').show();
    $('#user_name').focus();
    return false;
  });

  $('.set-avatar').submit(function(e) {
    $('.set-avatar-submit').attr('disabled', 'disabled');
    $(this).children('.loading-message').show();
  });

  $('.clear-avatar').submit(function(e) {
    if(confirm("Are you sure you want to clear your avatar?") == false) {
      e.preventDefault();
    }
  });

  $('.change-avatar-link').click(function(e) {
    mainProfileHeight = $('#main-profile-section').height();

    $('#main-profile-section').data('original-height', mainProfileHeight);
    $('#main-profile-section').height(mainProfileHeight + $('.avatar-controls').height() + 100);
    $('.avatar-controls').show();
    e.preventDefault();
  });

  $('html').click(function(){
    $(".bubbly").hide();
  });

  resizeFaceboxToFitSuggestions();

  $("#search_for_referrer .single_suggestion").live('click', fadeOutUnclickedSuggestions);

  $('.nav-contact-us').click(function(e){
    e.preventDefault();
    $('#IntercomDefaultWidget').click(); 
  });
});

function autoFocusColor(field, text){
  // Define Selectors
  field = $(field);
  
  // color class to add to suggestion text
  var color_class = 'grey';
  
  // Autofocus on the field
  field.focus();
  field.val('email');
  field.addClass(color_class);
  
  // Clear default text when typing
  field.keypress(function(key){
    if (text == field.val()){
      field.val('');
    }
    field.removeClass(color_class);
  })

  // Clear default text when clicked
  field.click(function(){
    if (field.val() == text){
      field.val('');          
    }
  });
  
  // Put default text up when you leave the field if nothing entered
  field.blur(function(){
    if (field.val() == ''){
      field.val(text);
      field.addClass(color_class);          
    }
  });
}

function launchTutorialIntroduction(){
  if (document.getElementById('tutorial_introduction')){
    mixpanelPagePingForTalkingChicken();
    var div = $('#tutorial_introduction');
    var intro_content = div.html();
    var options = {hideOnOverlayClick : false,
                    showCloseButton	 : false,
                    speedIn : 1200, // Time it takes to fade in the intro slide
                		speedOut : 200 // Time to fade out the intro slide if they decline
                  };
    $.fancybox(intro_content, options);
    div.hide();
  }
}

function mixpanelPagePingForTalkingChicken(){
  $.post('/ping', {page_name: 'talking chicken'});
}

function mixpanelPagePingForActivityFeed(){
  $.post('/ping', {page_name: 'activity feed'});
}

function hideTutorialIntroduction(){
  $('#fancybox-wrap').hide();
  $('#fancybox-overlay').hide();
}

function showTutorialIntroduction(){
  $('#fancybox-wrap').fadeIn(2777);
  $('#fancybox-overlay').fadeIn(5000);
}
