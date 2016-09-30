if (typeof console == "undefined") {
    this.console = {log: function() {}};
}

function countCSSRules() {
    var results = "Here are the results\n___________", 
        txt = '';
    if (!document.styleSheets) {
        return;
    }
    for (var i = 0; i < document.styleSheets.length; i++) {
        countSheet(document.styleSheets[i]);
    }
    function countSheet(sheet) {
        var count = 0;
      console.log(sheet.href);
        if (sheet && sheet.rules) {
            for (var j = 0, l = sheet.rules.length; j < l; j++) {
                if( !sheet.rules[j].selectorText ) {
                    continue;
                }
                count += sheet.rules[j].selectorText.split(',').length;
            }

            txt += '\nFile: ' + (sheet.href ? sheet.href : 'inline <style> tag');
            txt += '\nRules: ' + sheet.rules.length;
            txt += '\nSelectors: ' + count;
            txt += '\n--------------------------';
            if (count >= 3076) {
                results += '\n********************************\nWARNING:\n There
are ' + count + ' CSS rules in the stylesheet ' + sheet.href + ' - IE will
ignore the last ' + (count - 3076) + ' rules!\n';
            }
        }
    }
    console.log(txt);
    console.log(results);
};
countCSSRules();

