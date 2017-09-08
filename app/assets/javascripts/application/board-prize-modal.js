// TODO: This was a quick refactor to remove original prize code from the global namespace.  We should continue the refactor to use templates and better management of mobile.

var Airbo = window.Airbo || {};

Airbo.BoardPrizeModal = (function(){
  var selector = ".js-board-prize-modal";

  function init() {
    $(".close_modal").click(function(){
      closeModal();
    });

    $(selector).click(function(event){
      if($(event.target).is($(selector))){
        closeModal();
      }
    });

    $("#raffle_data").click(function(){
      showRaffleBox("Prize");
    });
  }

  function open() {
    if (showFinish()) {
      showRaffleBox("Prize Period Finished!", "Ok");
    } else if (showStart()) {
      showRaffleBox("New Prize!", "Start");
    } else {
      showRaffleBox("Prize", "Start");
    }
  }

  function showOnLoad() {
    if (!Airbo.BoardWelcomeModal.showOnLoad()) {
      return showStart() || showFinish();
    }
  }

  function showStart() {
    return $(selector).data("raffleShowStart") === true;
  }

  function showFinish() {
    return $(selector).data("raffleShowFinish") === true;
  }

  function showRaffleBox(header, button_text){
    $(".js-prize-header").text(header);
    $(".js-close-prize-modal").text(button_text);

    mq = window.matchMedia( "(min-width: 500px)" );
    if (mq.matches || window.oldBrowser) {
      // window width is at least 500px
      // $("#modal_link").click();
      $(".js-board-prize-modal").foundation('reveal', 'open');
    }
    else {
      // window width is less than 500px
      showRaffleMobile();
    }
  }

  function closeModal() {
    mq = window.matchMedia( "(min-width: 500px)" );
    if (mq.matches || window.oldBrowser) {
      $('[data-reveal]').foundation('reveal','close');
    }else{
      hideRaffleMobile();
    }
  }

  function showRaffleMobile(){
    $(".js-board-prize-modal").removeClass("reveal-modal");
    $(".content").children().slice(3).css("display", "none");
    $("footer").css("display", "none");
    $("body").css("background", "white");
    $(".jPanelMenu-panel").css("background", "white");
  }

  function hideRaffleMobile(){
    $(selector).addClass("reveal-modal");
    $(".content").children().slice(3).css("display", "block");
    $("footer").css("display", "block");
    $("jPanelMenu-panel").css("background", "");
    $(".content").css("background", "");
  }

  return {
    init: init,
    open: open,
    showOnLoad: showOnLoad
  };
}());
