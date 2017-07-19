
var Airbo = window.Airbo || {};

Airbo.StandardAnswer = Object.create(Airbo.BaseAnswer);

Airbo.StandardAnswer.init = function (config, container){

  Airbo.BaseAnswer.init.call(this, config, container); 

  this.answers = config.answers;
  this.correctAnswerIndex = config.index;
  this.extendable = config.extendable;
  this.wrongable = config.wrongable;
  this.points = config.points;
  this.maxLength = config.maxLength;
  this.exceed = config.exceed;
  this.allowFreeResponse = config.allowFreeResponse;
  this.freeResponse = config.freeResponse;

  this.setupAnswers();
  return this;
};

Airbo.StandardAnswer.render = function(){
  Airbo.BaseAnswer.render.call(this)

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
};

Airbo.StandardAnswer.includeAnswerAdder = function(){
  var panel
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

};

Airbo.StandardAnswer.removeAnswerAdder = function(){
  var answerAdder = document.querySelector(".js-add-answer");
  this.controlPanel.removeChild(answerAdder);
};

Airbo.StandardAnswer.answerNodes = function(){
  return this.answerPanel.querySelectorAll(".answer-div");
};

Airbo.StandardAnswer.includeAnswerRemovers = function() {
  var answers = this.answerNodes()
    , numAnswers = answers.length
    , i
  ;

  for ( i=0; i < numAnswers; i++) {
    this.addAnswerRemover(answers[i]);
  }
};

Airbo.StandardAnswer.addAnswerRemover = function(answer){
  var remover =document.createElement("i");
  remover.setAttribute('class', 'js-remove-answer fa fa-remove fa-1x ' );
  answer.appendChild(remover);
};

Airbo.StandardAnswer.addRadioButton = function(answer, value, checked){

  var radiobutton = document.createElement("input")
    , wrapper = document.createElement("div")
    , answerButton = answer.querySelector(".answer-btn")
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
};

Airbo.StandardAnswer.includeRadioButtons = function(){
  var checked
    , answers = this.answerNodes()
    , i
  ;
  for( i=0; i < answers.length; i++){
    checked = this.correctAnswerIndex === i ? true : false;
    this.addRadioButton(answers[i], i, checked);
  }
};


Airbo.StandardAnswer.setupAnswers = function(){
  var idx, numAnswers = this.answers.length
  ;

  for(idx = 0; idx < numAnswers; idx++){
    this.answerSet.push(this.createTileAnswerButton(this.answers[idx]));
  }
};

Airbo.StandardAnswer.buildAnswerNodeList = function() {
  return this.answerSet.map(function(answer) {
    return answer.asDomNode();
  });
};

Airbo.StandardAnswer.includeFreeResponse = function(){
  var checkbox = document.createElement("input")
    , hidden = document.createElement("input")
    , label = document.createElement("label")
    , btn = document.createElement("a")
    , tooltip = document.createElement("i")
    , tooltipTemplate = document.createElement("div")
    , tooltipContent = document.createElement("div")
    , node = document.createDocumentFragment()
    , btnClass = 'answer-btn no-edit js-btn-free-text'
    , answerWrapper
    , answerWrapperClass="answer-div js-free-text-btn-wrapper free-text-btn-wrapper"
  ;



  if(this.allowFreeResponse){
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

  tooltip.setAttribute('class', 'js-free-text-tooltip hover-help fa fa-question-circle fa-1x ' );

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
};

Airbo.StandardAnswer.addAnswer = function() {
  var len = this.answerPanel.querySelectorAll(".answer-div").length
    , answer = this.createTileAnswerButton("Add Answer Option")
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
};

Airbo.StandardAnswer.asDomNode = function() {
  var node = document.createDocumentFragment();

  this.buildAnswerNodeList().forEach(function(answerNode, index) {
    node.appendChild(this.answerWrapper(answerNode, index));
  }, this);

  return node
};


Airbo.StandardAnswer.createTileAnswerButton = function(answer){
  return Airbo.EditableTileAnswerButton.build(answer, this.maxLength, this.exceed);
};



