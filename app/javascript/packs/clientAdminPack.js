import Vue from "vue";
import Vuex from "vuex";
import TilesAppStore from "./vueApps/clientAdmin/tilesApp/store";
import TilesApp from "./vueApps/clientAdmin/tilesApp/App.vue";

Vue.use(Vuex);

const store = new Vuex.Store({
  ...TilesAppStore
});

document.addEventListener("DOMContentLoaded", () => {
  const clientAdminTilesApp = new Vue({
    el: "#vueClientAdminTiles",
    store,
    render: h => h(TilesApp)
  });

  console.log(clientAdminTilesApp.$store);
});
