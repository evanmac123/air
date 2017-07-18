Airbo.TileBuilderInteractionCharacterCounter =  {
  msg: "",

  init: function(max, remaining) {
    this.uniqueId = "counter" + Math.round(Math.random() * 10000000);
    this.remaining = remaining;
    this.max = max;
    this.msg = remaining +" Characters";
    return this;
  },

  asDomNode: function() {
    var node = document.createElement('div');
    node.setAttribute('id', this.uniqueId);
    node.setAttribute('class', 'character-counter');
    node.setAttribute('maxlength', this.max);
    node.insertAdjacentText('afterbegin', this.msg);
    return node;
  },

};


