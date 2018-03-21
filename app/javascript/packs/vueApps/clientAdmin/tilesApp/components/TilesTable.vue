<template>
  <div class="grid">
    <div class="v-tile-thumbnail">
      This container is <strong>centered</strong> on desktop.
    </div>
    <div class="v-tile-thumbnail">
      This container is <strong>centered</strong> on desktop.
    </div>
    <div class="v-tile-thumbnail">
      This container is <strong>centered</strong> on desktop.
    </div>
    <div class="v-tile-thumbnail">
      This container is <strong>centered</strong> on desktop.
    </div>
    <div class="v-tile-thumbnail">
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

.grid {
  display: grid;
  grid-template-columns: repeat(4, auto);
  grid-row-gap: 20px;
  justify-content: space-evenly;
  justify-items: center;
  padding: 50px;
}

</style>
