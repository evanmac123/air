var Airbo = window.Airbo || {};

Airbo.QuillStandaloneEditor = (function(){

  function removeTabEventsFromToolbar() {
    $(".ql-formats").children().attr("tabindex", "-1");
  }

  function setIcons() {
    var icons = Quill.import('ui/icons');
    icons.bold = '<i class="fa fa-bold" aria-hidden="true"></i>';
    icons.italic = '<i class="fa fa-italic" aria-hidden="true"></i>';
    icons.underline = '<i class="fa fa-underline" aria-hidden="true"></i>';
  }

  function toolbarOptions() {
    return {
      container: [
        ['bold', 'italic', 'underline'],
        [{ align: ''}, { align: 'center'}, { align: 'right'}, { align: 'justify'}],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        [{ 'color': [] }, { 'background': [] }],
        ['link'],
        ['insertName'],
        ['insertAirboLink']
      ],
      handlers: {
        'insertName': function() {
          var range = this.quill.getSelection();
          if (range) {
            this.quill.insertEmbed(range.index, "variable", "{{name}}");
            this.quill.setSelection(range.index + 1, Quill.sources.SILENT);
          }
        },
        'insertAirboLink': function() {
          var range = this.quill.getSelection();
          if (range) {
            this.quill.insertEmbed(range.index, "variable", "{{link_to_airbo}}");
            this.quill.setSelection(range.index + 1, Quill.sources.SILENT);
          }
        }
      }
    };
  }

  function init(editorSel) {
    // setIcons();
    quillEditor = new Quill(editorSel, {
      modules: {
        toolbar: toolbarOptions()
      },
      placeholder: 'Enter your message...',
      theme: 'snow'
    });

    removeTabEventsFromToolbar();
    return quillEditor;
  }

  return {
    init: init
  };

}());
