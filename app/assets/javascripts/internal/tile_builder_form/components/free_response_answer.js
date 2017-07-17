var Airbo = Airbo || {};

Airbo.FreeResponseAnswer = Object.create(BaseAnswer);

Airbo.FreeResponseAnswer.asDomNode = function() {
  var node = document.createDocumentFragment()
    , btn = document.createElement("a")
    , answers = document.createElement("input")
    , hidden = document.createElement("input")
    , freeText = document.createElement("textarea")
  ;


  answers.setAttribute('type','hidden');
  answers.setAttribute('name','tile[answers][]');
  answers.setAttribute('value','Submity My Response');

  hidden.setAttribute("type", "hidden");
  hidden.setAttribute("name", "tile[allow_free_response]");
  hidden.setAttribute("value", 1);

  btn.setAttribute('class', 'answer-btn btn-free-response js-answer-btn');
  btn.appendChild(document.createTextNode("Submit My Response"));

  freeText.setAttribute("class", "free-text");
  freeText.setAttribute("placeholder", "Enter your response here");

  node.appendChild(answers);
  node.appendChild(hidden);
  node.appendChild(freeText);
  node.appendChild(btn);
  return node;
};




