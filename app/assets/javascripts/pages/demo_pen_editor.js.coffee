intializeDemoPenEditor = ->
  options =
    editor: $("#demo_pen_editor")[0]
  editor = new Pen(options)

$ ->
  intializeDemoPenEditor()