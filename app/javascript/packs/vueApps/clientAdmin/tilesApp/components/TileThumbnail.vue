<template>
  <div class="v-tile-thumbnail">
    <p>hey</p>
    <div class="image">

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

<style lang="css" scoped>
.v-tile-thumbnail p {
  color: red;
}

</style>
