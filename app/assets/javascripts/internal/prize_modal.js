function bindPrizeModal(showStart, showFinish, publicSlug) {
  $().ready(function(){
    if(showFinish) {
      $(".prize_header .end_date").css("display", "none");
      $(".prize_header").css("text-align", "center");
      showRaffleBox("Prize Period Finished!", "Ok");
      prizeModalPing("Saw Prize Modal");
    } else if(showStart) {
      if( $("#get_started_lightbox").length == 0 && $('#activity-joyride').length == 0 ){ 
      // not display prize and get started box simultaneously
        showRaffleBox("New Raffle!");
        prizeModalPing("Saw Prize Modal");
      }else{
        window.showRaffleAfterLightbox = true;
      }
    }
  });
  $(".close_modal").click(function(){
    mq = window.matchMedia( "(min-width: 500px)" );
    if (mq.matches || window.oldBrowser) {
      $('[data-reveal]').foundation('reveal','close');
      }else{
        hideRaffleMobile();
      }
  });
  $("#raffle_data").click(function(){
    showRaffleBox("Prize");
    prizeModalPing("Clicked Prize Info");
  });
  function prizeModalPing(event){
    $.ajax({
      type: "POST",
      url: "/ping",
      data: { event: event, properties: { action: "Clicked Start", public_slug: publicSlug} }
    });
  }
  function showRaffleBox(header, button_text){
    button_text = typeof button_text !== 'undefined' ? button_text : "Start";

    $(".prize_header h1").text(header);
    $(".button.close_modal").text(button_text);
    mq = window.matchMedia( "(min-width: 500px)" );
    if (mq.matches || window.oldBrowser) {
      // window width is at least 500px
      $("#modal_link").click();
    }
    else {
      // window width is less than 500px
      showRaffleMobile();
    }
  }
  function showRaffleMobile(){
    $("#prize_modal").removeClass("reveal-modal");
    $(".content").children().slice(3).css("display", "none");
    $("footer").css("display", "none");
    $("body").css("background", "white");
    $(".jPanelMenu-panel").css("background", "white");
  }
  function hideRaffleMobile(){
    $("#prize_modal").addClass("reveal-modal");
    $(".content").children().slice(3).css("display", "block");
    $("footer").css("display", "block");
    $("jPanelMenu-panel").css("background", "");
    $(".content").css("background", "");
  }

  window.prizeModalPing = prizeModalPing;
  window.showRaffleBox = showRaffleBox;
};

