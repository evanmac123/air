import 'babel-polyfill';

import React from "react";
import ReactDOM from "react-dom";
import App from "../containers/app";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("ctrl-data");
  const initData = JSON.parse(node.getAttribute("data"));
  ReactDOM.render(
    <App initData={initData} />,
    document.getElementById("root")
  );
});
