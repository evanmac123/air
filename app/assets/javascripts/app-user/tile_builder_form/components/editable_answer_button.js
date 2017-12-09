var Airbo = window.Airbo || {};


Airbo.EditableTileAnswerButton = {

  init: function(text,config) {
    var remaining;

    this.maxLength = config.maxLength || 50;
    this.exceed = config.exceed || false;
    this.text = text
    remaining =  this.maxLength - text.length
    this.characterCounter = Airbo.TileBuilderComponentCharacterCounter.build(this.maxLength, remaining);
    return this;
  },

  asDomNode: function() {
    var node = document.createDocumentFragment()
      , textInput = document.createElement("textarea")
      , btn = document.createElement("a")
    ;

    textInput.setAttribute('rows', 1);
    textInput.setAttribute('maxlength', this.maxLength);
    textInput.setAttribute('class', 'answer-editable');
    textInput.setAttribute('name','tile[answers][]');
    textInput.setAttribute("data-counterid", this.characterCounter.uniqueId);
    textInput.setAttribute("data-exceed", this.exceeed);
    textInput.appendChild(document.createTextNode(this.text));


    btn.setAttribute('class', 'answer-btn js-answer-btn');
    btn.appendChild(document.createTextNode(this.text));

    node.appendChild(btn);
    node.appendChild(textInput);
    node.appendChild(this.characterCounter.asDomNode());
    return node;
  },

  build: function(answer, maxLength, exceed){
    return Object.create(this).init(answer, {maxLength: maxLength, exceed: exceed});
  }

};


