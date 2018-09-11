import 'babel-polyfill';
import React from "react";
import ReactDOM from "react-dom";
import ClientAdminTiles from "../containers/clientAdminTiles";

document.addEventListener("DOMContentLoaded", () => {
  // const node = document.getElementById("client-admin-tiles-data");
  // const data = JSON.parse(node.getAttribute("data"));
  ReactDOM.render(
    <ClientAdminTiles />,
    document.getElementById("client-admin-tiles-root")
  );
});
