var SimpleAnswer ={
  init: function (config, container){
    this.container = container;
    this.answerPanel = document.getElementById("quiz-answer");
    this.controlPanel = document.querySelector(".js-answer-controls");

    this.answerSet = [];

    this.answers = config.answers;
    this.correctAnswerIndex = config.index;
    this.extendable = config.extendable;
    this.wrongable = config.wrongable;
    this.points = config.points;
    this.maxLength = config.maxLength;
    this.exceed = config.exceed;
    this.freeResponseEnabled = config.freeResponseEnabled;
    this.freeResponse = config.freeResponse;

    this.answerBuilder = Airbo.TileBuilderAnswerFactory.get(config.answerType);
    this.setupAnswers();
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

    if(this.extendable){
      this.includeAnswerRemovers();
      this.includeAnswerAdder();
    }

    if(this.wrongable){
      this.includeRadioButtons();
    }

    if(this.freeResponse){
      this.includeFreeResponse();
    }
  },

  includeAnswerAdder: function(){
    var  panel
      , link
      , icon
      , linkText
    ;


    link = document.createElement("a");
    icon = document.createElement("i");
    linkText = document.createTextNode("Add another answer");

    link.setAttribute("class", "js-add-answer add_answer");
    icon.setAttribute("class", "fa fa-plus");

    link.appendChild(icon);
    link.appendChild(linkText);

    this.controlPanel.appendChild(link);

  },

  removeAnswerAdder: function(){
    var answerAdder = document.querySelector(".js-add-answer");
    this.controlPanel.removeChild(answerAdder);
  },

  answerNodes: function(){
    return this.answerPanel.querySelectorAll(".answer-div");
  },

  includeAnswerRemovers: function() {
    var answers = this.answerNodes()
      , numAnswers = answers.length
      , i
    ;

     for ( i=0; i < numAnswers; i++) {
       this.addAnswerRemover(answers[i]);
     }
  },

  addAnswerRemover: function(answer){
    var remover =document.createElement("i");
    remover.setAttribute('class', 'js-remove-answer fa fa-remove fa-1x ' );
    answer.appendChild(remover);
  },
  
  addRadioButton: function(answer, value, checked){

    var radiobutton = document.createElement("input")
      , wrapper = document.createElement("div")
      , answerButton = answer.querySelector(".answer-btn");
    ;

    radiobutton.setAttribute('type', 'radio');
    radiobutton.setAttribute('name', 'tile[correct_answer_index]');
    radiobutton.setAttribute('class', "correct-answer-button");

    radiobutton.setAttribute('value', value);
    if(checked){
      radiobutton.setAttribute('checked', 'checked');
    }

    wrapper.setAttribute("class", "tile-radio-button-wrapper");
    wrapper.appendChild(radiobutton);

    answer.insertBefore(wrapper, answerButton);
  },

  includeRadioButtons: function(){
    var checked
      , answers = this.answerNodes()
      , i
    ;
    for( i=0; i < answers.length; i++){
      checked = this.correctAnswerIndex === i ? true : false;
      this.addRadioButton(answers[i], i, checked);
    }
  }, 

  createSingleAnswer: function(answer){
    return Object.create(this.answerBuilder).init(answer, {maxLength: this.maxLength, exceed: this.exceed}); 
  },

  setupAnswers: function(){
    var idx, numAnswers = this.answers.length
    ;

    for(idx = 0; idx < numAnswers; idx++){
      this.answerSet.push(this.createSingleAnswer(this.answers[idx]));
    }
  },

  buildAnswerNodeList:   function() {
    return this.answerSet.map(function(answer) {
      return answer.asDomNode();
    });
  },

  includeFreeResponse: function(){
    var checkbox = document.createElement("input")
      , hidden = document.createElement("input")
      , label = document.createElement("label")
      , btn = document.createElement("a")
      , tooltip = document.createElement("i")
      , tooltipTemplate = document.createElement("div")
      , tooltipContent = document.createElement("div")
      , node = document.createDocumentFragment()
      , btnClass = 'answer-btn js-btn-free-text'
      , answerWrapper
      , answerWrapperClass="answer-div js-free-text-btn-wrapper free-text-btn-wrapper"
    ;



    if(this.freeResponseEnabled){
      checkbox.checked = true;
      answerWrapperClass += " enabled";
    }

    btn.setAttribute('class', btnClass);
    btn.appendChild(document.createTextNode("Other"));
    
    hidden.setAttribute('name', 'tile[allow_free_response]');
    hidden.setAttribute('type', 'hidden');
    hidden.setAttribute('value', "0");

    checkbox.setAttribute('type', 'checkbox');
    checkbox.setAttribute('class', 'js-chk-free-text free-response-toggle');
    checkbox.setAttribute('name', 'tile[allow_free_response]');

  
    label.setAttribute('class', 'js-free-response-toggle-wrapper free-response-toggle-wrapper')
    label.appendChild(hidden);
    label.appendChild(checkbox);
    label.appendChild(document.createTextNode("Allow Free Response"));

    tooltipTemplate.setAttribute('class', 'js-tooltip-template tooltip-template free-response' );
    tooltipContent.setAttribute('class', 'js-tooltip-content tooltip-content free-response' );

    tooltip.setAttribute('class', 'js-free-text-tooltip fa fa-question-circle fa-1x ' );

    tooltip.setAttribute('data-tooltip-content', ".js-tooltip-content.free-response");

    tooltipContent.appendChild(document.createTextNode("When users choose Other as their answer, they will be shown a free response text box."));
    tooltipTemplate.appendChild(tooltipContent);
    node.appendChild(btn);
    node.appendChild(tooltipTemplate);
    node.appendChild(tooltip);
    answerWrapper = this.answerWrapper(node)
    answerWrapper.setAttribute("class", answerWrapperClass);
    this.answerPanel.appendChild(answerWrapper);
    this.controlPanel.appendChild(label);
  },

  addAnswer: function() {
    var len = this.answerPanel.querySelectorAll(".answer-div").length
      , answer = this.createSingleAnswer("Add Answer Option")
      , wrapper = this.answerWrapper(answer.asDomNode(), len-1 )
      , freeTextBtn = document.querySelector(".js-free-text-btn-wrapper")
    ;

    if(this.wrongable){
      this.addRadioButton(wrapper);
    }

    if(this.extendable){
      this.addAnswerRemover(wrapper);
    }

    this.answerPanel.insertBefore(wrapper, freeTextBtn);
  },

  answerWrapper: function(answerNode, index) {
    var answerDiv = document.createElement("div");
    answerDiv.setAttribute('class', 'answer-div read-mode');
    answerDiv.setAttribute('data-index', index);
    answerDiv.appendChild(answerNode);
    return answerDiv;
  },

  asDomNode:  function() {
    var node = document.createDocumentFragment();

    this.buildAnswerNodeList().forEach(function(answerNode, index) {
      node.appendChild(this.answerWrapper(answerNode, index));
    }, this);

    return node
  },

}


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

  function init(config){
    question = config.question;
    resetAttributes(config.type, config.subtype);
    answer = Object.create(SimpleAnswer).init(config, container)
  }

  return {
    init: init, 
    render: render,
    addAnswer: addAnswer
  }
}());


