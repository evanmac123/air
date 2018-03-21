<template>
  <div class="container">
    <div class="notification">
      This container is <strong>centered</strong> on desktop.
    </div>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      id: 1,
      tile_status: "active",
      preview_path: "/client_admin/tiles",
      thumbnail_image: "https://vuejs.org/images/logo.png",
      activation_dates: "undefined",
      status_marker: "hey",
      headline: "hey"
    }
  }
}
</script>

<style scoped>
:root {
--mainColor: red;
}
p {
  color: var(--mainColor);
}

div {
  lost-waffle: 1/3;
}

</style>
