import React, { Component } from "react";
import PropTypes from "prop-types";

import { AiRouter } from "../../lib/utils";
import Explore from "../explore/ExploreContainer";
import ClientAdminTiles from "../clientAdminTiles/ClientAdminTilesContainer";

const routes = {
  '/explore': Explore,
  '/explore/campaigns/:campaign': Explore,
  '/client_admin/tiles': ClientAdminTiles,
};

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      currentRoute: '',
      routeData: {},
    };
    this.airouter = new AiRouter(routes, this);
  }

  componentDidMount() {
    this.airouter.connect();
  }

  componentWillUnmount() {
    this.airouter.disconnect();
  }

  render() {
    return React.createElement('div', {className: 'react-root'},
    this.state.currentRoute ?
      React.createElement(routes[this.state.currentRoute], {ctrl: this.props.initData, routeData: this.state.routeData}) :
      ''
    );
  }
}

App.propTypes = {
  initData: PropTypes.object,
};

export default App;
