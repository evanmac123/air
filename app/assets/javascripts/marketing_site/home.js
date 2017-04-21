//Disclaimer: This code was from a contractor (with slight restructuring). #gitblamelies.

var Airbo = window.Airbo || {};
Airbo.MarketingSite = Airbo.MarketingSite || {};

Airbo.MarketingSite.Home = (function(){
  function initHeaderMobileMenu() {
    $('.btn-menu').click(function() {
      $('.marketing-site-header').toggleClass('mobile-nav');
    });
  }

  function initInPageScrolling() {
    $('.inpage-paginator').find('a').click(function() {
      $.scrollTo(this.hash, 400, {
        offset: function() {
          return { top: -120 };
        }
      });

      return false;
    });
  }

  function initHeaderShadowOnScroll() {
    $(window).scroll(function() {
      if ( Math.floor($('.hero').outerWidth()) > 560 ) {
        var scrollPos = $(document).scrollTop(),
          heroH = $('.hero').outerHeight();
          if ( Math.floor(scrollPos) >= Math.floor(heroH) ) {
            $('#header').addClass('inside-page');
          } else {
            $('#header').removeClass('inside-page');
          }
      }
    });
  }

  function initScrollingOptions() {
    $(window).scroll(function() {
      // executes only if the browser width is >800px or desktop
      if ( Math.floor($('.hero').outerWidth()) < 800 ) {
        $('.inpage-paginator').fadeOut('fast');
        return;
      } else {
        var scrollPos = $(document).scrollTop(),
            heroW = $('.hero').outerWidth(),
            messageOff = $('.ceos-message').offset(),
            tileOff = $('.ft-tile').offset(),
            boardOff = $('.ft-board').offset(),
            topicsOff = $('.ft-topics').offset(),
            emailOff = $('.ft-email').offset(),
            metricsOff = $('.ft-metrics').offset(),
            successOff = $('.feature-success').offset();
        /**
        * show the in-page scroller only
        if the current page scroll position is within the range of CEO Message to Dedicated to Success
        */
        var pad = 360;
        var sp = Math.floor(scrollPos),
            me = Math.floor(messageOff.top) - pad,
            ti = Math.floor(tileOff.top) - pad,
            bo = Math.floor(boardOff.top) - pad,
            to = Math.floor(topicsOff.top) - pad,
            em = Math.floor(emailOff.top) - pad,
            mt = Math.floor(metricsOff.top) - pad,
            su = Math.floor(successOff.top) + pad;
        if ( sp >= me && sp <= su ) {
          $('.inpage-paginator').fadeIn('fast');
        } else {
          $('.inpage-paginator').fadeOut('fast');
        }
        /* Highlighy Currently active sections by comparing
        sections height and the current scroll position */
        var setActiveKey = function( key ) {
          $('.inpage-paginator').find('a[href="'+key+'"]').parent('li').addClass('active').siblings().removeClass('active');
        };

        if ( sp < me ) {
          setActiveKey('#ipnav-hero');
        } else if ( sp >= me && sp <= ti ) {
          setActiveKey('#ipnav-ceom');
        } else if ( sp >= ti && sp <= bo ) {
          setActiveKey('#ipnav-tile');
        } else if ( sp >= bo && sp <= to ) {
          setActiveKey('#ipnav-board');
        } else if ( sp >= to && sp <= em ) {
          setActiveKey('#ipnav-topics');
        } else if ( sp >= em && sp <= mt ) {
          setActiveKey('#ipnav-email');
        } else if ( sp >= mt && sp <= su ) {
          setActiveKey('#ipnav-metrics');
        } else {
          $('.inpage-paginator').find('li').removeClass('active');
        }
      }
    });
  }

  function init() {
    initHeaderMobileMenu();
    initInPageScrolling();
    initHeaderShadowOnScroll();
    initScrollingOptions();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".pages-home")) {
    Airbo.MarketingSite.Home.init();
  }
});
