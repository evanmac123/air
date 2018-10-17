import 'babel-polyfill';

import React from "react";
import ReactDOM from "react-dom";
import { Provider } from "react-redux";

import store from "../lib/redux/store";
import App from "../containers/app";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("ctrl-data");
  const initData = JSON.parse(node.getAttribute("data"));
  ReactDOM.render(
    <Provider store={store}>
      <App initData={initData} />
    </Provider>,
    document.getElementById("root")
  );
});
