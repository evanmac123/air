var Airbo = window.Airbo || {};

Airbo.TileStatsMessageEditor = (function() {
  var quillEditor;

  function init() {
    initEvents();
    quillEditor = Airbo.QuillStandaloneEditor.init("#tileStatsMessageEditor");
    return this;
  }

  function initEvents() {
    $(
      ".js-tile-targeted-message-scope-cd, .js-tile-targeted-message-answer-idx"
    ).on("change", function(e) {
      Airbo.TileStatsMessageSender.getRecipientCount();
    });
  }

  function message() {
    return quillEditor.root.innerHTML;
  }

  function textPresent() {
    return quillEditor.getText().length > 1;
  }

  function editor() {
    return quillEditor;
  }

  return {
    init: init,
    message: message,
    editor: editor
  };
})();
