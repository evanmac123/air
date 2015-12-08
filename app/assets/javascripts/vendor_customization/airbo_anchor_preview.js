var Airbo = window.Airbo || {};

Airbo.CustomAnchorPreview = MediumEditor.extensions.anchorPreview.extend({
  createPreview: function () {
    var el = this.document.createElement('div');

    el.id = 'medium-editor-anchor-preview-' + this.getEditorId();
    el.className = 'medium-editor-anchor-preview';
    el.innerHTML = this.getTemplate();

    editIcon = $(el).find("i")[0];
    this.on(editIcon, 'click', this.handleClick.bind(this));

    return el;
  },
  getTemplate: function () {
    return  '<div class="medium-editor-toolbar-anchor-preview" id="medium-editor-toolbar-anchor-preview">' +
            '  <a target="_blank"></a>' +
            '  <span class="sep-vertical medium-editor-toolbar-anchor-preview-inner"></span>' +
            '  <i class="fa fa-pencil"></i>' +
            '</div>';
  }
});
