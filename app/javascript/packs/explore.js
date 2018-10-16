import 'babel-polyfill';

import React from "react";
import ReactDOM from "react-dom";
import Explore from "../containers/explore";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("explore-data");
  const data = JSON.parse(node.getAttribute("data"));
  ReactDOM.render(
    <Explore ctrl={data} />,
    document.getElementById("explore-root")
  );
});
