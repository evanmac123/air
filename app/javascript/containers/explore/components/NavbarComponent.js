import React from "react";
import PropTypes from "prop-types";

const NavbarComponent = props => (
  <div className="row" style={{paddingTop: "20px"}}>
    <a onClick={props.navbarRedirect}>{"<  Back to Explore"}</a>
  </div>
);

NavbarComponent.propTypes = {
  navbarRedirect: PropTypes.func,
};

export default NavbarComponent;
