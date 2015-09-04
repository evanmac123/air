var Airbo = window.Airbo || {};

Airbo.TileSharingMgr = (function(){
  var tileStatusOff
    , tileStatusOn
    , shareableTileLink
    , tileStatusOffSelector = ".tile_status .off"
    , tileStatusOnSelector = ".tile_status .on"
    , shareableTileLinkSelector = "#sharable_tile_link"
  ;

  function initOnOffLinks(){

    $('#sharable_tile_link_on').click(function() {
      sendSharableTileForm();
      turnOnSharing();
    });

    $('#sharable_tile_link_off').click(function() {
      sendSharableTileForm();
      turnOffSharing();
    });
  }

  function initSharableTileEvents(){

   shareableTileLink.on('click', function(event) {
      event.preventDefault();
      $(event.target).focus().select();
    });

    shareableTileLink.on('keydown keyup keypress', function(event) {
      if (!(event.ctrlKey || event.altKey || event.metaKey)) {
       event.preventDefault();
      }
    });
  }

  function initShareViaLinks(){
    $(".share_via_linkedin, .share_via_facebook, .share_via_twitter").click(function(e) {
      var url;
      e.preventDefault();
      sharedViaSocialPing($(this));
      turnOnSharableTile();
      url = $(this).closest("a").attr("href");
      window.open(url, '', 'width=620, height=500');
    });

    $(".share_via_explore").click(function() {
      var selector = ".share_options"
        , shareOptions = $(selector)
      ;

      debugger
      sendTileSharedPing("Explore");
      turnOnSharableTile();
      shareOptions.show();
      shareOptions.find('.allow_copying').show();
      shareOptions.find('.add_tag').show();
    });

    return $(".share_via_email").click(function() {
      sendTileSharedPing("Email");
      turnOnSharableTile();
    });
  }

  function initPublicLinkCopyCut(){
   $("#share_link").bind({
      copy: function() {
        sendTileSharedPing("Via Link");
      },
      cut: function() {
        sendTileSharedPing("Via Link");
      }
    });
  }

  function sendSharableTileForm() {
     $("#sharable_link_form").submit();
  }

  function turnOnSharing() {
    tileStatusOff.removeClass("engaged").addClass("disengaged");
    tileStatusOn.removeClass("disengaged").addClass("engaged");
    sharableTileLink.removeAttr("disabled");
  }

  function turnOffSharing() {
    tileStatusOff.removeClass("disengaged").addClass("engaged");
    tileStatusOn.removeClass("engaged").addClass("disengaged");
    sharableTileLink.attr("disabled", "disabled");
  }

  function  sendTileSharedPing(shared_to) {
    var tile_id;
    tile_id = $("[data-current-tile-id]").data("current-tile-id");
    $.post("/ping", {
      event: 'Tile Shared',
      properties: {
        shared_to: shared_to,
        tile_id: tile_id
      }
    });
  }

  function sharedViaSocialPing(element) {
    if (element.hasClass("share_via_facebook")) {
      sendTileSharedPing("Facebook");
    } else if (element.hasClass("share_via_twitter")) {
      sendTileSharedPing("Twitter");
    } else if (element.hasClass("share_via_linkedin")) {
      sendTileSharedPing("Linkedin");
    }
  }

  function turnOnSharableTile() {
    if ($(".tile_status .on.disengaged").length > 0) {
      $('#sharable_tile_link_on').click();
      sendSharableTileForm();
    }
  }

  function initJQueryObjects(){
    tileStatusOff= $(tileStatusOffSelector);
    tileStatusOn = $(tileStatusOnSelector);
    shareableTileLink= $(shareableTileLinkSelector);
  }

  function init(){
    initJQueryObjects();
    initOnOffLinks();
    initSharableTileEvents();
    initShareViaLinks();
    initPublicLinkCopyCut();
  }

  return{
    init: init
  };

}());


window.shareSectionIntro = function() {
  var intro;
  intro = introJs();
  intro.setOptions({
    showStepNumbers: false,
    skipLabel: 'Got it, thanks',
    tooltipClass: 'tile_preview_intro'
  });
  return $(function() {
    return intro.start();
  });
};
