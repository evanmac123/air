var global_fade_out_time88374635134 = 300;

$(function() {
  var this_div = $("#sort_by_first_name");
  var other_div = $("#sort_by_points");
  this_div.click(function(){
    fadeOutScoreboard();
    this_div.addClass('active');
    other_div.removeClass('active');
  });
  
  other_div.click(function(){
    fadeOutFriendsList();
    other_div.addClass('active');
    this_div.removeClass('active');
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
