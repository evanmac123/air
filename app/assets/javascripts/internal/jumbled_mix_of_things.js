var global_contents_of_three_ways_to_play_3838477463535 = '';

$(function() {
  
  saveFaqMiniToVariable();  
  
  $("#command_central").click(function(){
    $('.bubbly').hide();
  });
  
  if (document.getElementById('command_central')){
    $('#command_central').focus();
    var sugg = "Answer a tile";
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
    $('#IntercomDefaultWidget').click(); 
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

