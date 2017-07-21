var Airbo = Airbo || {};

Airbo.FreeResponseAnswer = Object.create(Airbo.BaseAnswer);

Airbo.FreeResponseAnswer.render = function(){
  Airbo.BaseAnswer.render.call(this)

  this.renderOptionalFeatures();

};

Airbo.FreeResponseAnswer.asDomNode = function() {
  var node = document.createDocumentFragment()
    , btn = document.createElement("a")
    , answers = document.createElement("input")
    , freeText = document.createElement("textarea")
  ;


  answers.setAttribute('type','hidden');
  answers.setAttribute('name','tile[answers][]');
  answers.setAttribute('value','Submity My Response');

  btn.setAttribute('class', 'answer-btn btn-free-response js-answer-btn');
  btn.appendChild(document.createTextNode("Submit My Response"));

  freeText.setAttribute("class", "js-free-form-response free-text-entry");
  freeText.setAttribute("placeholder", "Enter your response here");
  node.appendChild(answers);
  node.appendChild(freeText);
  node.appendChild(btn);
  return node;
};




