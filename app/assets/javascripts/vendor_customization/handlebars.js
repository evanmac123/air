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

Handlebars.registerHelper("formatLocalTime", function(utc, format) {
  var utcTime = moment.utc(utc).toDate();
  return moment(utcTime)
    .local()
    .format(format);
});

Handlebars.registerHelper("numAddCommas", function(num) {
  if (num) {
    return num.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
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

Handlebars.registerHelper("link", function(text, options) {
  var attrs = [];

  for (var prop in options.hash) {
    attrs.push(
      Handlebars.escapeExpression(prop) +
        '="' +
        Handlebars.escapeExpression(options.hash[prop]) +
        '"'
    );
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
    "==": function(l, r) {
      return l == r;
    },
    "===": function(l, r) {
      return l === r;
    },
    "!=": function(l, r) {
      return l != r;
    },
    "<": function(l, r) {
      return l < r;
    },
    ">": function(l, r) {
      return l > r;
    },
    "<=": function(l, r) {
      return l <= r;
    },
    ">=": function(l, r) {
      return l >= r;
    },
    typeof: function(l, r) {
      return typeof l == r;
    }
  };

  if (!operators[operator]) {
    throw new Error(
      "Handlerbars Helper 'compare' doesn't know the operator " + operator
    );
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

Handlebars.registerHelper("toJSON", function(string) {
  return JSON.stringify(string);
});

Handlebars.registerHelper("renderPartial", function(template, options) {
  return new Handlebars.SafeString(HandlebarsTemplates[template](options.hash));
});

Handlebars.registerHelper("truncate", function(str, len) {
  if (str && str.length > len) {
    var newStr = str + " ";
    newStr = str.substr(0, len);
    newStr = str.substr(0, newStr.lastIndexOf(" "));
    newStr = newStr.length > 0 ? newStr : str.substr(0, len);
    return new Handlebars.SafeString(newStr + "...");
  }

  return str;
});

Handlebars.registerHelper("decorateUriForTileStats", function(uri) {
  if (uri.includes("s3.amazonaws.com/tile_attachments")) {
    uri = uri.split("/").pop();
  }

  return Handlebars.helpers.truncate(uri, 65);
});

Handlebars.registerHelper("uriEncode", function(uri) {
  return encodeURI(uri);
});

Handlebars.registerHelper("select", function(value, options) {
  // Create a select element
  var select = document.createElement("select");

  // Populate it with the option HTML
  $(select).html(options.fn(this));

  //below statement doesn't work in IE9 so used the above one
  //select.innerHTML = options.fn(this);

  // Set the value
  select.value = value;

  // Find the selected node, if it exists, add the selected attribute to it
  if (select.children[select.selectedIndex]) {
    select.children[select.selectedIndex].setAttribute("selected", "selected");
  } else {
    //select first option if that exists
    if (select.children[0]) {
      select.children[0].setAttribute("selected", "selected");
    }
  }
  return select.innerHTML;
});
