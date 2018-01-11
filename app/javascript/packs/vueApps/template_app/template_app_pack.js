import Vue from "vue";
import App from "./components/app.vue";

document.addEventListener("DOMContentLoaded", () => {
  const app = new Vue({
    el: "#vue-app",
    render: h => h(App)
  });

  console.log(app);
});
