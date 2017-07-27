
Airbo.TileInteractionBuilder = (function(){
  var question, answer, container;

  function resetAttributes(type, subtype) {
    container = document.getElementById("js-interaction-container");
    container.setAttribute("class", type + "-interaction " + subtype);
  }


  function renderQuestion () {
    var textArea = document.getElementById("tile_question")
    textArea.innerText = question
  }

  function render() {
    answer.render();
    renderQuestion();
  }

  function addAnswer(){
    answer.addAnswer();
  }


  function init(config,savedQuestion){
    var builder = config.builder || Airbo.StandardAnswer;

    question = savedQuestion || config.question
    resetAttributes(config.type, config.subtype);
    answer = Object.create(builder).init(config, container)
  }

  return {
    init: init, 
    render: render,
    addAnswer: addAnswer
  }
}());


