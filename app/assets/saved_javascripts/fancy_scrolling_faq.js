var last_scroll_pos = 0;
var masthead_height = 241;
var toc_div = $("#faq_toc .floating_toc");
var body_div = $("#faq_body");
var toc_height = 0;
var already_attached = 0;

$(function(){
  getTocHeight(); // sets the global varialbe toc_height
  
  // alert('screen height: ' + getScreenHeight());
  //   alert('scroll position: ' + getScrollPos());
    // 
    //repositionElements();
    $(window).scroll(function(){
      repositionElements();
    });

  
  
});

function repositionElements(){
  var pushing_up = pushingUp();
  var pushing_down = 1;
  if (pushing_up){
    pushing_down = 0;
  }
  console.log('pushing up: ' + pushing_up)
  if (getScrollPos() < masthead_height){
    resetPositionToDefault();
    console.log('in masthead');
  }else if (pushing_up && !tocBottomVisible()){   
    attachToBody();
    console.log(1);
  }else if (pushing_down && !tocTopVisible() ){ 
    attachToBody();
    console.log(2);
    
  }else if(pushing_up && tocBottomVisible()){
    changeToFixedBottom();

    console.log(3);
  }else if(pushing_down && tocTopVisible()){
    changeToFixedTop();
    console.log(4);
  }
  // if pushing up and bottom of toc not yet visible || pushing down and top of toc not yet visible
      // attach to body and scroll with it
  
  // if pushing up and bottom of toc already reached, change to fixed, aligning bottom of div with bottom of window
    
  // if pushing down and top of toc already reached, change to fixed, aligning top of div with top of window
}

function getTocHeight(){
  toc_height = toc_div.height();
  return toc_height;
}

function getTocPosition(){
  var pos = toc_div.position().top;
  return pos;
}

function attachToBody(){
  if (already_attached){
    //
  }else{
    toc_div.css('top', getScrollPos()  + getScreenHeight() - toc_height - masthead_height);
    //toc_div.css('top', getTocPosition());
    toc_div.css('position', 'relative');
    toc_div.css('bottom', 'inherit')
    
    already_attached = 1;
  }
}

function resetPositionToDefault(){
  toc_div.css('position', 'static');
}

function changeToFixedTop(){
  toc_div.css('position', 'fixed');
  toc_div.css('top', 0);
  toc_div.css('bottom', 'inherit')
  already_attached = 0;
}

function changeToFixedBottom(){
  toc_div.css('position', 'fixed');
  toc_div.css('bottom', 0);
  toc_div.css('top', 'inherit')
  already_attached = 0;
}

function putRightUnderMasthead(){
  toc_div.css('position', 'static');
}

function topAlignDivWithWindow(){
  //
}

function bottomAlignDivWithWindow(){
  //
}

function tocTopVisible(){
  var position = toc_div.position().top;
  var scroll_pos = getScrollPos();
  if (position >= scroll_pos){
    return 1;
  }else{
    return 0;
  }
}

function tocBottomVisible(){
  var position = toc_div.position().top;
  var scroll_pos = getScrollPos();
  var screen_height = getScreenHeight();
  if (position + toc_height <= scroll_pos + screen_height){
    return 1;
  }else{
    return 0;
  }
}

function pushingUp(){
  var internal_last_scroll_pos = last_scroll_pos;
  var scroll_pos = getScrollPos();
  if (scroll_pos > internal_last_scroll_pos){
    return 1;
  }else{
    return 0;
  }
}

function pushingDown(){
  if(pushingUp()){
    return 0;
  }else{
    return 1;
  }
}
// the functions getScreenHeight and getScrollPos were adapted from:
// http://www.howtocreate.co.uk/tutorials/javascript/browserwindow
function getScreenHeight() {
  var screen_height = 0;
  if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    screen_height = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ){
    //IE 6+ in 'standards compliant mode'
    screen_height = document.documentElement.clientHeight;
  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    screen_height = document.body.clientHeight;
  }
  return screen_height;
}

function getScrollPos() {
  var scroll_pos = 0;
  if( typeof( window.pageYOffset ) == 'number' ) {
    //Netscape compliant
    scroll_pos = window.pageYOffset;
  } else if( document.body && ( document.body.scrollTop ) ) {
    //DOM compliant
    scroll_pos = document.body.scrollTop;
  } else if( document.documentElement && ( document.documentElement.scrollTop ) ) {
    //IE6 standards compliant mode
    scroll_pos = document.documentElement.scrollTop;
  }
  last_scroll_pos = scroll_pos;
  return scroll_pos ;
}