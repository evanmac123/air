var Airbo = window.Airbo || {};

Airbo.CustomAnchorForm = MediumEditor.extensions.anchor.extend({
  linkValidation: true,
  // Called when the button the toolbar is clicked
  // Overrides ButtonExtension.handleClick
  handleClick: function (event) {
      event.preventDefault();
      event.stopPropagation();

      var range = MediumEditor.selection.getSelectionRange(this.document);

      if (range.startContainer.nodeName.toLowerCase() === 'a' ||
          range.endContainer.nodeName.toLowerCase() === 'a' ||
          MediumEditor.util.getClosestTag(MediumEditor.selection.getSelectedParentElement(range), 'a')) {
          return this.execAction('unlink');
      }

      if (!this.isDisplayed()) {
          link = $(MediumEditor.selection.getSelectionHtml(this.document));
          var opt = null;
          if (link.attr("href")) {
            opt = {
              url: link.attr("href"),
              target: link.attr('target'),
              buttonClass: link.attr('class')
            }
          }
          this.showForm(opt);
      }

      return false;
  }
});
