$(document).ready(function() {
  connectPersonas();
  connectTour();
  connectSolutions();
});

// Homepage personas module
function connectPersonas(){
  $('.a-feature').hover(function() {
      //hide
      $('.a-feature').removeClass('selected');
      $('div.employee li').hide();
      $('div.employee-quote li').hide();
      //show
      $(this).addClass('selected');
      $('div.employee li.'+this.id).show();
      $('div.employee-quote li.'+this.id).show();
  });
}

// Product Tour: Achieve Perpectual Engagement
function connectTour(){
  $('#perpeng #perpeng-features li').hover(function() {
      $('#perpeng #perpeng-features li').removeClass('selected');
      $('#perpeng div.image img').hide();

      $(this).addClass('selected');
      $('#perpeng div.image img.'+this.id).show();
  });

  //tooltips
  $('.pt a.callout').mouseover(function(pos) {
    $('div#'+this.id+'-tt').css({
      left:pos.pageX, top:pos.pageY
    }).fadeIn(300);
  }).mousemove(function(pos2) {
    $('div#'+this.id+'-tt').css({
      left:pos2.pageX-100, top:pos2.pageY+15
    })
  }).mouseout(function(){
    $('div#'+this.id+'-tt').fadeOut(300);
  });
}

// Solutions page
function connectSolutions(){
  $('ul.a-solution').click(function() {
      $('section.offering-section').hide();
      $('a.solution-name').removeClass('selected');

      $('section#'+this.id+'-section').fadeIn();
      $('ul.a-solution#'+this.id+' a.solution-name').addClass('selected');
  });

  $('#next-post').click(function() {
    $('section.offering-section').hide();
    $('a.solution-name').removeClass('selected');
    $('section.offering-section#post-section').fadeIn();
    $('ul.a-solution#post a.solution-name').addClass('selected');
  });
  $('#next-play').click(function() {
    $('section.offering-section').hide();
    $('a.solution-name').removeClass('selected');
    $('section.offering-section#play-section').fadeIn();
    $('ul.a-solution#play a.solution-name').addClass('selected');
  });
}
