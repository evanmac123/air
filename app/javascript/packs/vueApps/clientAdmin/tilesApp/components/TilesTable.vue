<template>
  <div class="grid">
    <div v-for="tile in tiles">

    </div>
  </div>
</template>

<script>
import {Sortable} from '@shopify/draggable';


export default {
  data: function () {
    return {
      tiles: this.$state.tiles
    }
  },
  mounted() {
    new Sortable(document.querySelectorAll('.grid'), {
      draggable: '.v-tile-thumbnail',
    });
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
