import Vue from "vue";
import TilesApp from "./vueApps/clientAdmin/tilesApp/App.vue";

document.addEventListener("DOMContentLoaded", () => {
  const clientAdminTilesApp = new Vue({
    el: "#vueClientAdminTiles",
    render: h => h(TilesApp)
  });

  console.log(clientAdminTilesApp);
});
