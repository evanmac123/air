Handlebars.registerHelper("debugger", function(optionalValue) {
  console.log("Current Context");
  console.log("====================");
  console.log(this);

  if (optionalValue) {
    console.log("Value");
    console.log("====================");
    console.log(optionalValue);
  }
});

Handlebars.registerHelper('formatLocalTime', function(utc, format) {
  var utcTime = moment.utc(utc).toDate();
  return moment(utcTime).local().format(format);
});

Handlebars.registerHelper("numAddCommas", function(num) {
  if (num) {
    return num.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
  } else {
    return 0;
  }
});

Handlebars.registerHelper("pluralize", function(num, singular, plural) {
  if (num === 1) {
    return singular;
  } else {
    return plural;
  }
});

Handlebars.registerHelper("arrExists", function(arr) {
  return arr !== undefined || arr.length !== 0;
});

Handlebars.registerHelper('link', function(text, options) {
  var attrs = [];

  for (var prop in options.hash) {
    attrs.push(
      Handlebars.escapeExpression(prop) + '="' + Handlebars.escapeExpression(options.hash[prop]) + '"');
  }

  return new Handlebars.SafeString(
    "<a " + attrs.join(" ") + ">" + Handlebars.escapeExpression(text) + "</a>"
  );
});

Handlebars.registerHelper("compare", function(lvalue, rvalue, options) {
  if (arguments.length < 3) {
    throw new Error("Handlebars Helper 'compare' needs 2 parameters");
  }

  var operator = options.hash.operator || "==";

  var operators = {
    '==':       function(l,r) { return l == r; },
    '===':      function(l,r) { return l === r; },
    '!=':       function(l,r) { return l != r; },
    '<':        function(l,r) { return l < r; },
    '>':        function(l,r) { return l > r; },
    '<=':       function(l,r) { return l <= r; },
    '>=':       function(l,r) { return l >= r; },
    'typeof':   function(l,r) { return typeof l == r; }
  };

  if (!operators[operator]) {
    throw new Error("Handlerbars Helper 'compare' doesn't know the operator " +  operator);
  }

  var result = operators[operator](lvalue, rvalue);

  if (result) {
    return options.fn(this);
  } else {
    return options.inverse(this);
  }
});

Handlebars.registerHelper("math", function(lvalue, operator, rvalue, options) {
    lvalue = parseFloat(lvalue);
    rvalue = parseFloat(rvalue);

    return {
        "+": lvalue + rvalue,
        "-": lvalue - rvalue,
        "*": lvalue * rvalue,
        "/": lvalue / rvalue,
        "%": lvalue % rvalue
    }[operator];
});

Handlebars.registerHelper('toJSON', function(string) {
    return JSON.stringify(string);
});
