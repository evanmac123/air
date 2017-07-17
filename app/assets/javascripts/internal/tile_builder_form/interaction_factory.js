
Airbo.TileInteractionBuilder = (function(){
  var question, answer, container;

  function resetAttributes(type, subtype) {
    container = document.getElementById("js-interaction-container");
    container.setAttribute("class", type + "-interaction " + subtype);
  }


  function renderQuestion () {
    var textArea = document.getElementById("tile_question")
    textArea.innerText =question
  }

  function render() {
    answer.render();
    renderQuestion();
  }

  function addAnswer(){
    answer.addAnswer();
  }

  function answerType(type){
    switch(type){
      case "free_response":
        return Airbo.FreeResponseAnswer;
      default:
        return Airbo.StandardAnswer;
    }
  }

  function init(config){
    var answerObject = answerType(config.subtype)
    question = config.question;
    resetAttributes(config.type, config.subtype);
    answer = Object.create(answerObject).init(config, container)
  }

  return {
    init: init, 
    render: render,
    addAnswer: addAnswer
  }
}());


