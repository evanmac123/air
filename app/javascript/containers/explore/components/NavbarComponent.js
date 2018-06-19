import React from "react";
import PropTypes from "prop-types";

const NavbarComponent = props => (
  <div className="row" style={{paddingTop: "20px"}}>
    <span className="large-12 columns">
      <a
        style={{paddingLeft: "10px"}}
        onClick={props.navbarRedirect}
      >
        {"<  Back to Explore"}
      </a>
    </span>
  </div>
);

NavbarComponent.propTypes = {
  navbarRedirect: PropTypes.func,
};

export default NavbarComponent;
