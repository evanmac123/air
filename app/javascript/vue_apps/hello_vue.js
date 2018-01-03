import Vue from "vue";
import App from "../components/app.vue";

document.addEventListener("DOMContentLoaded", () => {
  document.body.appendChild(document.createElement("vueApp"));
  const app = new Vue({
    render: h => h(App)
  }).$mount("vueApp");

  console.log(app);
});
