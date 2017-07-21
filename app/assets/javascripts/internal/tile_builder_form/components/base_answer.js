var Airbo = Airbo || {};

Airbo.BaseAnswer = {
  init: function (config, container){
    this.container = container;
    this.answerPanel = document.getElementById("quiz-answer");
    this.controlPanel = document.querySelector(".js-answer-controls");
    this.answerSet = [];
    this.optionalFeatures = []
    this.answers = config.answers;
    this.allowAnonymous = config.allowAnonymous;
    this.isAnonymous = config.isAnonymous;
    this.setupOptionalFeatures();
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

  wrapOptionToggler: function(opt){
    var wrapper = document.createElement("div");
    wrapper.setAttribute('class', 'left tile-option');
    wrapper.appendChild(opt);
    return wrapper;
  },

  createOptionsPanel: function(){
    var options = document.createElement("div");

    options.setAttribute("class", "optional-tile-features");

    this.controlPanel.appendChild(options);
    this.optionsPanel = options;

  },

  answerWrapper: function(answerNode, index) {
    var answerDiv = document.createElement("div");
    answerDiv.setAttribute('class', 'answer-div read-mode');
    answerDiv.setAttribute('data-index', index);
    answerDiv.appendChild(answerNode);
    return answerDiv;
  },

  includeAllowAnonymous: function(){
    var checkbox = document.createElement("input")
      , hidden = document.createElement("input")
      , label = document.createElement("label")
    ;

    if(this.isAnonymous){
      checkbox.checked = true;
    }

    hidden.setAttribute('name', 'tile[is_anonymous]');
    hidden.setAttribute('type', 'hidden');
    hidden.setAttribute('value', "0");

    checkbox.setAttribute('type', 'checkbox');
    checkbox.setAttribute('class', 'js-chk-anonymous-reponse chk-tile-optional-feature-toggle');
    checkbox.setAttribute('name', 'tile[is_anonymous]');

    label.setAttribute('class', 'tile-optional-feature-toggle-wrapper')
    label.appendChild(hidden);
    label.appendChild(checkbox);
    label.appendChild(document.createTextNode("Make Tile Anonymous"));
    return label
  },

  setupOptionalFeatures: function(){
    if(this.allowAnonymous){
      this.optionalFeatures.push(this.includeAllowAnonymous.bind(this))
    }
  },

  renderOptionalFeatures: function(){
    if(this.optionalFeatures.length > 0){
      this.createOptionsPanel();
      this.optionalFeatures.forEach(function(featureAdder){
        var optToggler = featureAdder.call(this);
        this.optionsPanel.appendChild(this.wrapOptionToggler(optToggler));
      }.bind(this))
    }
  }

};


