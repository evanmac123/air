var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.mediumEditor = (function() {
  var editor, field, fieldName;

  function reset(){
    if(editor){
      editor.destroy();
    }
  }

  function initExtensions(){

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
          selectionStr = MediumEditor.selection.getSelectionHtml(this.document);
          selectionHTML = $.parseHTML( selectionStr );
          link = $(selectionHTML);
          var opt = null;
          if (selectionHTML[0].nodeName.toLowerCase() == 'a' && link.attr("href")) {
            opt = {
              url: link.attr("href"),
              target: link.attr('target'),
              buttonClass: link.attr('class')
            }
            this.showForm(opt);
          } else {
            this.showForm();
          }
        }

        return false;
      }
    });


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

  }


  function init(params) {
    params = params || {};
    reset();
    initExtensions();

    $('.medium-editable').each(function(){

      defaultParams = {
        extensions: {
          anchorPreview: new Airbo.CustomAnchorPreview(),
          anchor:  new Airbo.CustomAnchorForm()
        },
        staticToolbar:true,
        buttonLabels: 'fontawesome',
        targetBlank: true,
        // anchor: {
        //   linkValidation: true,
        // },
        toolbar: {
         buttons: ['bold', 'italic', 'underline', 'unorderedlist', 'orderedlist', "anchor"]
        }
      };

      editor = new MediumEditor(this, $.extend(defaultParams, params) );
      editor.trigger("focus");

      fieldName = $(this).data('field')
      field = $("#" + fieldName);
      content =  field.val();
      field.data("oldVal", content);
      editor.setContent(content);

      editor.subscribe('blur', function (event, editable) {
        var obj =$(editable)
          ,  textLength = obj.text().trim().length
          , val = obj.html()
          , oldVal = field.data("oldVal")
          , re = new RegExp( /(<p><br><\/p>)+$/g)
        ;

        field.val( val.replace(re, "") );
        field.data("oldVal", field.val());

        if(oldVal !== field.val()){
          setTimeout(function(){
            field.change();
          }, 0)
        }
      });


      editor.subscribe('editableInput', function (event, editable) {
        var obj =$(editable),  textLength = obj.text().trim().length;

        if(textLength > 0){
          field.val(obj.html());
        }else{
          field.val("");
        }

        field.blur();
      });

    })
  }

  return {
    init: init
  };

}());
