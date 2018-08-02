import * as throttle from "lodash.throttle";

class InfiniScroller {
  constructor(opts) {
    this.scrollPercentageMet = this.scrollPercentageMet.bind(this);
    this.scrollPercentage = opts.scrollPercentage || 0.90;
    this.throttleAmount = opts.throttle || 95;
    this.onScrollCb = opts.onScroll;
  }

  scrollPercentageMet() {
    const { body, documentElement } = document;
    const supportPageOffset = window.pageXOffset !== undefined;
    const CSS1Compat = ((document.compatMode || "") === "CSS1Compat") ? document.documentElement.scrollTop : document.body.scrollTop;
    const scrollTop = supportPageOffset ? window.pageYOffset : CSS1Compat;
    const documentHeight = Math.max( body.scrollHeight, body.offsetHeight, documentElement.clientHeight, documentElement.scrollHeight, documentElement.offsetHeight );
    const bodyHeight = documentHeight - window.innerHeight;

    return ((scrollTop / bodyHeight) > this.scrollPercentage);
  }

  setOnScroll() {
    if (!this.onScrollCb) { throw new Error('`onScroll` parameter not established in constructor. `onScroll` is required.'); }
    window.addEventListener("scroll", throttle(() => {
      if (this.scrollPercentageMet()) { this.onScrollCb(); }
    }, this.throttleAmount), false);
  }

  removeOnScroll() {
    window.addEventListener("scroll", throttle(() => {
      if (this.scrollPercentageMet()) { this.onScrollCb(); }
    }, this.throttleAmount), false);
  }
}

export default InfiniScroller;
