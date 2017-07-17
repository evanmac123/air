var Airbo = Airbo || {};

Airbo.BaseAnswer = {
  init: function (config, container){
    this.container = container;
    this.answerPanel = document.getElementById("quiz-answer");
    this.controlPanel = document.querySelector(".js-answer-controls");
    this.answerSet = [];
    this.answers = config.answers;

    return this;
  },
  addErrorLabel: function(){
    var errorLabel = document.createElement("span");
    errorLabel.setAttribute("id", "tile_error");
    errorLabel.setAttribute("class", "err");

    this.controlPanel.appendChild(errorLabel)
  },

  reset: function(){
    this.controlPanel.innerHTML ='';
    this.answerPanel.innerHTML = '';
    this.addErrorLabel();
  },

  render: function(){
    this.reset();
    this.answerPanel.appendChild(this.asDomNode());
  },



  answerWrapper: function(answerNode, index) {
    var answerDiv = document.createElement("div");
    answerDiv.setAttribute('class', 'answer-div read-mode');
    answerDiv.setAttribute('data-index', index);
    answerDiv.appendChild(answerNode);
    return answerDiv;
  }

};


