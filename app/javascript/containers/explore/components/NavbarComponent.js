import React from "react";
import PropTypes from "prop-types";

const NavbarComponent = props => (
  <section className="with-divider pt-0">
    <div className="row campaign-nav-row">
      <div className="large-12 columns">
        <div className="campaign-nav-links" style={{display: "inherit"}}>
          <div
            className="campaign-nav-image-container"
            style={{backgroundImage: "explore_campaign_nav_link_image"}}
            onClick={props.navbarRedirect}
            data-name="Explore"
          >
            <div className="campaign-nav-shadow-overlay"></div>
            <div className="campaign-nav-overlay"></div>
            <h3 className="name">Explore</h3>
          </div>
        </div>
      </div>
    </div>
  </section>
);

// <% campaigns.each do |campaign| %>
// <% if campaign.display_tiles.present? %>
// <div className="carousel-cell campaign-nav-image-container" style="background-image: url('<%= campaign_nav_tile_image(campaign) %>')" data-id="<%= campaign.id %>" data-name="<%= campaign.name %>" data-id="<%= campaign.id %>" data-path="<%= explore_campaign_path(campaign) %>">
// <div className="campaign-nav-shadow-overlay"></div>
// <div className="campaign-nav-overlay"></div>
// <h3 className="name"><%= campaign.name  %></h3>
// </div>
// <% end %>
// <% end %>
NavbarComponent.propTypes = {
  navbarRedirect: PropTypes.func,
};

export default NavbarComponent;
