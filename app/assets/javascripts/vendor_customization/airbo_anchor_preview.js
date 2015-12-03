var Airbo = window.Airbo || {};

Airbo.CustomAnchorPreview = MediumEditor.extensions.anchorPreview.extend({
  getTemplate: function () {
    return  '<div class="medium-editor-toolbar-anchor-preview" id="medium-editor-toolbar-anchor-preview">' +
            '  <a class="medium-editor-toolbar-anchor-preview-inner"></a>' +
            '</div>';
  }
});
