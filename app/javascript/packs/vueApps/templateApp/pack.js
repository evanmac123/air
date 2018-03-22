// Example pack tags to add in head.
// <%= javascript_pack_tag 'vueApps/templateApp/pack' %>
// <%= stylesheet_pack_tag 'vueApps/templateApp/pack' %>

import Vue from "vue";
import Vuex from "vuex";
import Store from "./store";
import App from "./App.vue";

Vue.use(Vuex);

const store = new Vuex.Store({
  ...Store
});

document.addEventListener("DOMContentLoaded", () => {
  const VueApp = new Vue({
    el: "#app",
    store,
    render: h => h(App)
  });

  console.log(VueApp);
});
