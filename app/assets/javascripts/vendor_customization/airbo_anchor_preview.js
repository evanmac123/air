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
  },
  attachToEditables: function () {
    // show link preview on click instead of mouse over
    this.subscribe('editableClick', this.handleEditableMouseover.bind(this));
  },
  handleEditableMouseover: function (event) {
    var target = MediumEditor.util.getClosestTag(event.target, 'a');

    if (false === target) {
        return;
    }

    // Detect empty href attributes
    // The browser will make href="" or href="#top"
    // into absolute urls when accessed as event.target.href, so check the html
    if (!/href=["']\S+["']/.test(target.outerHTML) || /href=["']#\S+["']/.test(target.outerHTML)) {
        return true;
    }

    // only show when toolbar is not present
    var toolbar = this.base.getExtensionByName('toolbar');
    if (!this.showWhenToolbarIsVisible && toolbar && toolbar.isDisplayed && toolbar.isDisplayed()) {
        return true;
    }

    // detach handler for other anchor in case we hovered multiple anchors quickly
    if (this.activeAnchor && this.activeAnchor !== target) {
        this.detachPreviewHandlers();
    }

    this.anchorToPreview = target;
    // Using setTimeout + delay because:
    // - We're going to show the anchor preview according to the configured delay
    //   if the mouse has not left the anchor tag in that time
    this.base.delay(function () {
        if (this.anchorToPreview) {
            this.showPreview(this.anchorToPreview);
        }
    }.bind(this));
  },
  handlePreviewMouseout: function (event) {
    if ($(event.target).parents('.medium-editor-anchor-preview').length <= 0) {
        this.hidePreview();
        $('body').off("click", '', this.instanceHandlePreviewMouseout);
    }
  },
  attachPreviewHandlers: function () {
    this.instanceHandlePreviewMouseout = this.handlePreviewMouseout.bind(this);
    // actually it's click outside preview
    $('body').click(this.instanceHandlePreviewMouseout);
  }
});
