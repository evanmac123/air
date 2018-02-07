var Airbo = window.Airbo || {};

Airbo.TileBuilderComponentCharacterCounter = {
  msg: "",

  init: function(max, remaining) {
    this.uniqueId = "counter" + Math.round(Math.random() * 10000000);
    this.remaining = remaining;
    this.max = max;
    this.msg = remaining + " Characters";
    return this;
  },

  asDomNode: function() {
    var node = document.createElement("div");
    node.setAttribute("id", this.uniqueId);
    node.setAttribute("class", "tile-builder-component character-counter ");
    node.setAttribute("maxlength", this.max);
    node.insertAdjacentText("afterbegin", this.msg);
    return node;
  },

  build: function(maxLength, remaining) {
    return Object.create(this).init(maxLength, remaining);
  }
};
