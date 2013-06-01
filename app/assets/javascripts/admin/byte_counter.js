function lengthInBytes(string) {
  var result = 0;
  for(i = 0; i < string.length; i++) {
    var code = string.charCodeAt(i);
    if(code < 128) {
      result += 0.875;
    } else {
      while(code > 0) {
        result += 1;
        code >>= 8;
      }
    }
  }

  return result;
}

function updateByteCount(from, to) {
  maxLength = $(from).attr('maxlength');
  currentLength = lengthInBytes($(from).val());
  $(to).text('' + ((maxLength * 7 / 8) - currentLength) + ' bytes left');
}

function addCounter(locator, countUpdater) {
  var ghettoUniqueId = "counter_" + Math.round(Math.random() * 10000000);
  $(locator).after('<span class="character-counter" id="' + ghettoUniqueId + '"></span>');
  countUpdater(locator, '#'+ghettoUniqueId);
  // I'm using keyup here instead of keypress so that it plays nicely in Chrome
  $(locator).keyup(function() {
    // Put a tiny timeout in this so it waits for the data to hit the field before it calculates it
    setTimeout(function(){
      countUpdater(locator, '#'+ghettoUniqueId);
    }, 1);
  });
}

function addByteCounterFor(locator) {
  addCounter(locator, updateByteCount)
}


