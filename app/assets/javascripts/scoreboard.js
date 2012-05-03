var global_fade_out_time88374635134 = 300;

$(function() {
  var this_div = $("#username_header");
  var other_div = $("#userlevel_header");
  this_div.click(function(){
    fadeOutScoreboard();
    setTimeout(function(){
      this_div.addClass('active');
      other_div.removeClass('active');
    }, global_fade_out_time88374635134 / 2);
  });
  
  other_div.click(function(){
    fadeOutFriendsList();
    setTimeout(function(){
      other_div.addClass('active');
      this_div.removeClass('active');
    }, global_fade_out_time88374635134 / 2);
  });
  
  
});

function fadeOutScoreboard(){
  $("#friends_list").fadeOut(global_fade_out_time88374635134);
  $("#scoreboard_list").fadeOut(global_fade_out_time88374635134, fadeInFriendsList);
}
function fadeOutFriendsList(){
  $("#scoreboard_list").fadeOut(global_fade_out_time88374635134);
  $("#friends_list").fadeOut(global_fade_out_time88374635134, fadeInScoreboard);
}
function fadeInScoreboard(){
  $("#scoreboard_list").fadeIn(global_fade_out_time88374635134);
}
function fadeInFriendsList(){
  $("#friends_list").fadeIn(global_fade_out_time88374635134);
}
