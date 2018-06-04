import React, { Component } from 'react';

class App extends Component {
  constructor(props) {
    super(props)
    this.state = {
      loggedIn: false,
      loading: false,
      newUserForm: false,
      errorMessage: '',
    };
  }

  render() {
    return (
      <div className="App">
        <header className="App-header">
          <h1 className="App-title">Airbo on React</h1>
        </header>
      </div>
    );
  }
}

export default App;
