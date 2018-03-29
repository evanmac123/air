/*  jQuery Airbo Nice Select
    Made by Hernán Sartorio, updated by Nick Weiland */

(function($) {
  $.fn.niceSelect = function(method) {
    // Methods
    if (typeof method === "string") {
      if (method === "update") {
        this.each(function() {
          var $select = $(this);
          var $dropdown = $(this).next(".nice-select");
          var open = $dropdown.hasClass("open");

          if ($dropdown.length) {
            $dropdown.remove();
            createNiceSelect($select);
            $select.trigger("change");

            if (open) {
              $select.next().trigger("click");
            }
          }
        });
      } else if (method === "destroy") {
        this.each(function() {
          var $select = $(this);
          var $dropdown = $(this).next(".nice-select");

          if ($dropdown.length) {
            $dropdown.remove();
            $select.css("display", "");
          }
        });
        if ($(".nice-select").length === 0) {
          $(document).off(".nice_select");
        }
      } else {
        console.log('Method "' + method + '" does not exist.');
      }
      return this;
    }

    // Hide native select
    this.hide();

    // Create custom markup
    this.each(function() {
      var $select = $(this);

      if (!$select.next().hasClass("nice-select")) {
        createNiceSelect($select);
      }
    });

    function createNiceSelect($select) {
      var $options = $select.find("option");
      var $selected = $select.find("option:selected");
      var $dropdown = $("<div></div>")
        .addClass("nice-select")
        .addClass($select.attr("class") || "")
        .addClass($select.attr("disabled") ? "disabled" : "")
        .attr("tabindex", $select.attr("disabled") ? null : "0")
        .html('<span class="current"></span><ul class="list"></ul>');

      $select.after($dropdown);

      $dropdown
        .find(".current")
        .html($selected.data("display") || $selected.text());

      $options.each(function() {
        var $option = $(this);
        var display = $option.data("display") || null;
        var $optionListItem = $("<li/>")
          .data(
            $.extend($option.data(), { value: $option.val(), display: display })
          )
          .addClass(
            "option" +
              ($option.is(":selected") ? " selected" : "") +
              ($option.is(":disabled") ? " disabled" : "")
          )
          .addClass($option.attr("class"))
          .html($option.text());

        $optionListItem.appendTo($dropdown.find("ul"));
      });
    }

    /* Event listeners */

    // Unbind existing events in case that the plugin has been initialized before
    $(document).off(".nice_select");

    // Open/close
    $(document).on("click.nice_select", ".nice-select", function() {
      var $dropdown = $(this);

      $(".nice-select")
        .not($dropdown)
        .removeClass("open");
      $dropdown.toggleClass("open");

      if ($dropdown.hasClass("open")) {
        $dropdown.find(".option");
        $dropdown.find(".focus").removeClass("focus");
        $dropdown.find(".selected").addClass("focus");
      } else {
        $dropdown.focus();
      }
    });

    // Close when clicking outside
    $(document).on("click.nice_select", function(event) {
      if ($(event.target).closest(".nice-select").length === 0) {
        $(".nice-select")
          .removeClass("open")
          .find(".option");
      }
    });

    // Option click
    $(document).on(
      "click.nice_select",
      ".nice-select .option:not(.disabled)",
      function() {
        var $option = $(this);
        var $dropdown = $option.closest(".nice-select");
        var text = $option.data("display") || $option.text();

        $dropdown.find(".selected").removeClass("selected");
        $option.addClass("selected");
        $dropdown.find(".current").text(text);

        $dropdown
          .prev("select")
          .val($option.data("value"))
          .trigger("change");
      }
    );

    return this;
  };
})(jQuery);
