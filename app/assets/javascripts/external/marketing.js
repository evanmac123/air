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
}

// Solutions page
function connectSolutions(){
  $('ul.a-solution').click(function() {
      $('#offerings .wrap').hide();
      $('#measure ul').hide();
      $('a.solution-name').removeClass('selected');

      $('#'+this.id+'-feats').fadeIn();
      $('#'+this.id+'-measure').fadeIn();
      $('ul.a-solution#'+this.id+' a.solution-name').addClass('selected');
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
