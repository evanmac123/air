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

function maxLength(element) {
  return($(element).attr('maxlength'));
}

function canExceedMaxlength(element) {
  return $(element).attr('exceed_maxlength');
}

function exceededMaxLength(locator, counter, leftLength){
  if( !canExceedMaxlength(locator) ) return;
  if( leftLength < 0 ) {
    $(locator).addClass("exceeded_maxlength_field");
    $(counter).addClass("exceeded_maxlength_counter");
  } else {
    $(locator).removeClass("exceeded_maxlength_field");
    $(counter).removeClass("exceeded_maxlength_counter");
  }
}

function updateByteCount(from, to) {
  currentLength = lengthInBytes(currentText(from));
  $(to).text('' + ((maxLength(to) * 7 / 8) - currentLength) + ' bytes left');
}

function currentText(field) {
  if( $(field).is("input") || $(field).is("textarea") ) {
    return $(field).val();
  } else {
    return $(field).text();
  }
}

function updateCharacterCount(from, to) {
  currentLength = currentText(from).length;
  leftLength = maxLength(to) - currentLength;
  $(to).text('' + leftLength + ' characters');
  exceededMaxLength(from, to, leftLength)
}

function addCounter(locator, countUpdater) {
  var ghettoUniqueId = "counter_" + Math.round(Math.random() * 10000000);

  maxlength = $(locator).attr('maxlength'); // copy maxlength to counter
  if( canExceedMaxlength(locator) ) $(locator).removeAttr('maxlength');
  $(locator).after('<span class="character-counter" id="' + ghettoUniqueId + '" maxlength="' + maxlength + '"></span>');

  countUpdater(locator, '#'+ghettoUniqueId);
  // I'm using keyup here instead of keypress so that it plays nicely in Chrome
  $(locator).bind( "keyup DOMSubtreeModified", function() {
    // Put a tiny timeout in this so it waits for the data to hit the field before it calculates it
    setTimeout(function(){
      countUpdater(locator, '#'+ghettoUniqueId);
    }, 1);
  });
  return ghettoUniqueId;
}

function addByteCounterFor(locator) {
  return addCounter(locator, updateByteCount);
}

function addCharacterCounterFor(locator) {
  return addCounter(locator, updateCharacterCount);
}
