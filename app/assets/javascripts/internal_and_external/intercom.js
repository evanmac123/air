var addWordsAfterWindowLoads, addWordsToMessageBox, connectClickWidget, delay, h1_greeting, header, intercom, loadDivs, widget;

$(function() {
  loadDivs();
  return connectClickWidget();
});

delay = function(ms, func) {
  return setTimeout(func, ms);
};

intercom = header = h1_greeting = widget = 0;

loadDivs = function() {
  intercom = $('#IntercomNewMessageContainer');
  header = intercom.find('.header');
  h1_greeting = header.find('h1');
  widget = $('#IntercomDefaultWidget');
};

addWordsAfterWindowLoads = function() {
  if ($('#IntercomNewMessageContainer .header h1').length > 0) {
    loadDivs();
    return addWordsToMessageBox();
  } else {
    return delay(1, function() {
      return addWordsAfterWindowLoads();
    });
  }
};

addWordsToMessageBox = function() {
  return h1_greeting.after("<h2>Ask us a question or offer suggestions, and<br>we'll get back to you soon!</h2>");
};

connectClickWidget = function() {
  return widget.live('click', function() {
    return addWordsAfterWindowLoads();
  });
};
