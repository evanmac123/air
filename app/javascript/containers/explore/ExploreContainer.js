import React, { Component } from "react";

class Explore extends Component {
  constructor(props) {
    super(props);
    this.state = {
      loggedIn: false,
      loading: false,
      newUserForm: false,
      errorMessage: ""
    };
  }

  render() {
    return (
      <div className="App">
        <header className="App-header">
          <h1 className="App-title">Explore on React</h1>
        </header>
      </div>
    );
  }
}

export default Explore;
