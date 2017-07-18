Airbo.TileBuilderAnswerFactory = (function(){
  var BaseAnswer
    , ButtonAnswer
    , FreeFormAnswer
 ;

  /*
   * ----------------------------------------------------
   * Base answer
   * has text field and charactor counter
   * -----------------------------------------------------
   */

  ButtonAnswer = {

    init: function(text,config) {
      var remaining;

      this.maxLength = config.maxLength || 50;
      this.exceed = config.exceed || false;
      this.text = text
      remaining =  this.maxLength - text.length

      this.characterCounter = Object.create(Airbo.TileBuilderInteractionCharacterCounter).init(this.maxLength, remaining);
      return this;
    },

    asDomNode: function() {
      var node = document.createDocumentFragment()
        , textInput = document.createElement("textarea")
        , btn = document.createElement("a")
      ;

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

  };




 FreeFormAnswer = Object.create(ButtonAnswer);

  FreeFormAnswer.asDomNode = function() {
    var node = ButtonAnswer.asDomNode.call(this)
        , freeText = document.createElement("textarea")
       ,  btn =  node.querySelector(".answer-btn")
    ;

    freeText.setAttribute("class", "free-text");
    freeText.setAttribute("placeholder", "Enter your response here");
    node.insertBefore(freeText, btn);
    return node;
  };


  function get(name){
    switch(name){
      case "action":
        case "quiz":
        case "survey":
        return ButtonAnswer;
      case "action_free_form":
        return FreeFormAnswer;
      case "freeform":
        return FreeFormAnswer;
    }
  }


  return{
    get: get,
  }

}())
