var global_fade_out_time88374635134 = 500;

$(function() {
  $("#sort_by_first_name").click(function(){
    fadeOutScoreboard();
  });
  
  $("#sort_by_points").click(function(){
    fadeOutFriendsList();
  });
  
  
});

function fadeOutScoreboard(){
  boldSortByName();
  $("#scoreboard_list").fadeOut(global_fade_out_time88374635134, fadeInFriendsList);
}
function fadeOutFriendsList(){
  boldSortByPoints();
  $("#friends_list").fadeOut(global_fade_out_time88374635134, fadeInScoreboard);
}
function fadeInScoreboard(){
  $("#scoreboard_list").fadeIn(global_fade_out_time88374635134);
}
function fadeInFriendsList(){
  $("#friends_list").fadeIn(global_fade_out_time88374635134);
}
function boldSortByName(){
  $("#sort_by_first_name").addClass('bold');
  $("#sort_by_points").removeClass('bold');
}
function boldSortByPoints(){
  $("#sort_by_first_name").removeClass('bold');
  $("#sort_by_points").addClass('bold');
}