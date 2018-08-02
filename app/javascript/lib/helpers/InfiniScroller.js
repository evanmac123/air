import * as throttle from "lodash.throttle";
import * as $ from "jquery";

class InfiniScroller {
  constructor(opts) {
    this.scrollPercentage = opts.scrollPercentage || 0.90;
    this.throttleAmount = opts.throttle || 95;
    this.onScrollCb = opts.onScroll;
  }

  setOnScroll() {
    window.addEventListener("scroll", throttle(() => {
      const scrollTop = $(document).scrollTop();
      const windowHeight = $(window).height();
      const bodyHeight = $(document).height() - windowHeight;
      if ((scrollTop / bodyHeight) > this.scrollPercentage) { this.onScrollCb(); }
    }, this.throttleAmount), false);
  }

  removeOnScroll() {
    window.removeEventListener("scroll", throttle(() => {
      const scrollTop = $(document).scrollTop();
      const windowHeight = $(window).height();
      const bodyHeight = $(document).height() - windowHeight;
      if ((scrollTop / bodyHeight) > this.scrollPercentage) { this.onScrollCb(); }
    }, this.throttleAmount), false);
  }
}

export default InfiniScroller;
