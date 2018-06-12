import React from "react";
import ReactDOM from "react-dom";
import Explore from "../containers/explore";

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <Explore />,
    document.getElementById("explore-root")
  );
});
