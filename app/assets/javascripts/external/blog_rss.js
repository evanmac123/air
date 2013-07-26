// Latest blog feed
$(function(){
  $.ajax({
    type: "GET" ,
    url: "http://blog.hengage.com/?json=1" ,
    dataType: "jsonp" ,
    success: lastPosts
  });
});

// Change the slice nums to show more or less
function lastPosts(json) {
  var allPosts = json.posts;
  $(allPosts).slice(0, 3).each(function() {
    var postTitle = this.title;
    var postDescription = this.excerpt;
    var sentences = postDescription.split('.');
    var shortDescription = sentences[0] + '. ' + sentences[1] + '. ';
    var postURL = this.url;
    var featuredPostArea = $('.latest_3');
    featuredPostArea.append(
      '<li class="large-4 columns a_post"><div class="post_title"><a href="'+postURL+'" target="_new">'+postTitle+'</a></div><div class="post_description">'+shortDescription+'</div></li>'
    );
  });
}