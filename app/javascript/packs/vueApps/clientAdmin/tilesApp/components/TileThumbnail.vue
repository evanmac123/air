<template>
  <div class="v-tile-thumbnail">
    <div class="image">

    </div>
  </div>
</template>



<style scoped>
.v-tile-thumbnail {
  width: 256px;
  height: 320px;
  border-radius: 4px;
  background-color: #ffffff;
  box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.18);
}

.v-tile-thumbnail .image {
  width: 256px;
  height: 320px;
  border-radius: 4px;
  background-color: #ffffff;
  box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.18);
}

.v-tile-thumbnail .headline {
  width: 236px;
  height: 80px;
  font-family: AvenirNext;
  font-size: 18px;
  font-weight: 500;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-align: left;
  color: #454545;
}
</style>

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
