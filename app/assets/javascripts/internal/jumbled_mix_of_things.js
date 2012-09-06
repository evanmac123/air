var global_contents_of_three_ways_to_play_3838477463535 = '';

$(function() {
  
  saveFaqMiniToVariable();  
  
  $("#command_central").click(function(){
    $('.bubbly').hide();
  });
  
  if (document.getElementById('command_central')){
    $('#command_central').focus();
    var sugg = "Enter an action";
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


  $('#lots_of_friends').live('click', function(){
    $('.second_half').show();
    $(this).hide();
	  $('#facebox,.popup,.content').css("height","500px");
  });
  
  if (document.getElementById('invite_friends_facebox')){
    $.facebox({ div: '#invite_friends_facebox' });

    if (document.getElementById('email_prepends_0')){
      $('#facebox #email_prepends_0').focus();
      // For now, don't show the invite friends thing on the underlay
      $('#invite_friends_facebox').html('');
      
      // UNCOMMENT the following when you remove the line above
      // var prep = '#email_prepends_';
      // for (var i=0; i<10; i++){ // change these id's so there are no duplicates on the
      //   $('#facebox ' + prep + i).attr('id', prep + i + '_facebox');
      // }

    }else{
      hideAndRenamePageBasedInviteFriends();
      $(document).bind('close.facebox', function() { 
        moveInviteFriendsFaceboxToPage();
        launchTutorialIntroduction(); 
        $('.helper').hide();
      });
      $('#facebox #autocomplete').focus();
    }

  }else{
    launchTutorialIntroduction();
  }
  
  $('#show_tutorial').click(function(){
    showTutorial();
  });
    
    
  
  
  $('[id^=email_prepends]').blur(function(){
    setTimeout('calculatePoints()', 500);
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

  // 
  // // These next two are to make the autocompletions disappear if you click on something else
  // $('html').click(function() {
  //   setTimeout('$("#suggestions").html("")', 50);
  //   $('#suggestions').hide();
  //   clearAutocompleteStatus();
  //   resizeFaceboxToFitSuggestions();
  // });
  
  $('html').click(function(){
    $(".bubbly").hide();
  });

  resizeFaceboxToFitSuggestions();
  $("#search_for_referrer .single_suggestion").live('click', fadeOutUnclickedSuggestions);

  $('.nav-contact-us').click(function(e){
    e.preventDefault();
    $('.assistly-widget a').click(); 
  });
});

function saveFaqMiniToVariable(){
  global_contents_of_three_ways_to_play_3838477463535 = $("#faq_mini").html();
  $('#faq_mini').remove();  
}

function fancyBoxFaqMini(){
  // A 100ms delay is given so that if the href is '#', which may take you to the 
  // top of the page, it will wait till you get there before it paints the modal
  setTimeout('$.fancybox(global_contents_of_three_ways_to_play_3838477463535)', 100);
  mpq.track('saw minifaq');
}

function hideAndRenamePageBasedInviteFriends(){
  $('#invite_friends_facebox').html('');  
  $('#invite_friends_facebox').attr('id', 'temporary_div_name');  
}

function moveInviteFriendsFaceboxToPage(){
  var stuff_in_facebox = $('#facebox .content').html();
  //$('#facebox').remove();
  $('#temporary_div_name').html(stuff_in_facebox); 
  $('#temporary_div_name').attr('id', 'invite_friends');
  $('.autocomplete').css('opacity', 1);
  
}

function calculatePoints(){
  // here we will see how many email addresses were entered and apply points accordingly
  var number_emails = 0;
  var points_per_ref = $('#points_per_referral').text();
  if (points_per_ref == ''){
    $('#bonus').html('This game does not have referral bonuses set up yet.');
  }else{
    points_per_ref = parseInt(points_per_ref);
    var which_div = '';
    var div_contents = '';
    for (var i=0; i<10; i++){
      which_div = 'email_prepends_' + i;
      div_contents = document.getElementById(which_div).value;
      if (div_contents != ''){
        number_emails += 1;
      }
    }
    var total_potential = number_emails * points_per_ref;
    if (total_potential > 0) {
      $('#bonus').show();
    }
    $('#potential_bonus_points').text(total_potential);
  }
}




function lengthInBytes(string) {
  var result = 0;
  for(i = 0; i < string.length; i++) {
    var code = string.charCodeAt(i);
    if(code < 128) {
      result += 0.875;
    } else {
      while(code > 0) {
        result += 1;
        code >>= 8;
      }
    }
  }

  return result;
}

function updateCharacterCounter(from, to) {
  maxLength = $(from).attr('maxlength');
  currentLength = lengthInBytes($(from).val());
  $(to).text('' + ((maxLength * 7 / 8) - currentLength) + ' bytes left');
}

function addByteCounterFor(locator) {
  var ghettoUniqueId = "counter_" + Math.round(Math.random() * 10000000);
  $(locator).after('<span class="character-counter" id="' + ghettoUniqueId + '"></span>');
  updateCharacterCounter(locator, '#'+ghettoUniqueId);
  // I'm using keyup here instead of keypress so that it plays nicely in Chrome
  $(locator).keyup(function() {
    // Put a tiny timeout in this so it waits for the data to hit the field before it calculates it
    setTimeout(function(){
      updateCharacterCounter(locator, '#'+ghettoUniqueId);
    }, 1);
    
  });
}

// function hideTutorial(){
//   setTimeout("$('#black_tooltip').hide()", 1); // delayed so it waits till it shows up before hiding it
//   setTimeout("$('.overlay').hide()", 1); // delayed so it waits till it shows up 
// }
// function showTutorial(){
//   $('#black_tooltip').show();
//   $('.overlay').show();
// }

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
                    speedIn : 4000,
                		speedOut : 2000
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




function enclosingSelect(target) {
  /* Some clients treat the option tag as the target of this, others the 
   select tag--which is exactly the kind of nonsense jQuery is supposed to 
   gloss over. */
  return $(target).closest('select').first();
}
