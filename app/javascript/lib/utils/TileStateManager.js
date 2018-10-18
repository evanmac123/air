import React from "react";
import { connect } from "react-redux";
import { setUserData, setTilesData } from "../redux/actions";

class TileStateManager extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return null;
  }
}

export default connect(
  null,
  { setUserData, setTilesData}
)(TileStateManager);
