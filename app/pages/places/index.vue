<script setup lang="ts">
const pocketbase = usePocketbase();

// you can also fetch all records at once via getFullList
const records = await pocketbase.collection('places').getFullList(200 /* batch size */, {
    sort: '-created',
});

</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-8">
    <div class="surface-card p-4 shadow-2 border-round md:w-6 lg:w-4">
        <ul v-for="record in records">
          <li>{{ record.name }}</li>
          <li>{{ record.ort }}</li>
          <li>{{ record.year }}</li>
        </ul>
    </div>
  </div>
</template>
