Airbo.TileBuilderInteractionMenuBuilder = (function(){

  function buildMenu(){
    var interactions = Airbo.TileBuilderInteractionConfig.interactionSet();
    var dropdownMenuGroup= document.createElement("ul");
    var types = Object.keys(interactions);
    var interaction;
    var dropDownTriggerLink ;
    var interactionVariantsList;
    var caret;
    var variants;
    var variantDropdownMenu;

    dropdownMenuGroup.setAttribute("class", "button-group");

    for(var idx = 0; idx < types.length; idx++) {
      interaction = types[idx];
      variants = Object.keys(interactions[interaction]);
      dropDownTriggerLink = document.createElement("a");
      interactionVariantsList = document.createElement("li");
      caret = document.createElement("i");
      variantDropdownMenu= document.createElement("ul");
      interactionVariantsList.setAttribute("class", "tile_type");

      dropDownTriggerLink.setAttribute("id", interaction);
      dropDownTriggerLink.setAttribute("data-dropdown","drop_" + interaction );
      dropDownTriggerLink.setAttribute("class", "button type dropdown");
      dropDownTriggerLink.appendChild(document.createTextNode(interaction + " "));
      dropDownTriggerLink.appendChild(caret);

      caret.setAttribute("class", "js-menu-toggle fa fa-caret-down");

      variantDropdownMenu.setAttribute("id", "drop_" + interaction);
      variantDropdownMenu.setAttribute("class", "f-dropdown");
      variantDropdownMenu.setAttribute("data-dropdown-content",undefined);

      interactionVariantsList.appendChild(dropDownTriggerLink);

      variants.forEach(function(key) {
        var variant = interactions[interaction][key];
        var variantListItem = document.createElement("li");

        config = JSON.stringify({type: interaction, subtype: key});
        variantListItem.setAttribute("class", "subtype " + interaction + " " + key);

        variantListItem.setAttribute("data-config", config);
        variantListItem.appendChild(document.createTextNode(variant.name));
        variantDropdownMenu.appendChild(variantListItem);
      });

      interactionVariantsList.appendChild(variantDropdownMenu);
      dropdownMenuGroup.appendChild(interactionVariantsList);
    }

    return dropdownMenuGroup;
  }

  function render(){
    var menu = document.getElementById("interaction-menu");
    menu.appendChild(buildMenu());
  }

  return {
    render: render
  };

}());
