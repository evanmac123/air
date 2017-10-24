var Airbo = Airbo || {};

Airbo.FreeResponseAnswer = Object.create(Airbo.BaseAnswer);

Airbo.FreeResponseAnswer.render = function(){
  Airbo.BaseAnswer.render.call(this);
  this.renderOptionalFeatures();
};

Airbo.FreeResponseAnswer.asDomNode = function() {
  var node = document.createDocumentFragment();
  var btn = document.createElement("a");
  var answers = document.createElement("input");
  var freeText = document.createElement("textarea");

  this.characterCounter = Airbo.TileBuilderComponentCharacterCounter.build(400, 400);
  answers.setAttribute('type','hidden');
  answers.setAttribute('name','tile[answers][]');
  answers.setAttribute('value','Submity My Response');

  btn.setAttribute('class', 'answer-btn btn-free-response js-answer-btn');
  btn.appendChild(document.createTextNode("Submit"));

  freeText.setAttribute("class", "js-free-form-response free-text-entry");
  freeText.setAttribute("placeholder", "Enter your response here");
  freeText.setAttribute("maxLength", 400);

  freeText.setAttribute("data-counterid", this.characterCounter.uniqueId);
  node.appendChild(answers);
  node.appendChild(freeText);
  node.appendChild(this.characterCounter.asDomNode());
  node.appendChild(btn);
  return node;
};
