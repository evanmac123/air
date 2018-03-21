import Vue from "vue";
import App from "./App.vue";

document.addEventListener("DOMContentLoaded", () => {
  const clientAdminTilesApp = new Vue({
    el: "#clientAdminTilesVueApp",
    render: h => h(App)
  });

  console.log(clientAdminTilesApp);
});
