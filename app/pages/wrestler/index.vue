<script setup lang="ts">
const pocketbase = usePocketbase();

// you can also fetch all records at once via getFullList
const records = await pocketbase.collection('wrestler').getList(1, 50, {
    filter: 'created >= "2022-01-01 00:00:00"',
});

</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-8">
    <div class="surface-card p-4 shadow-2 border-round md:w-6 lg:w-4">
        <ul v-for="record in records.items">
          <li>{{ record.nummer }}</li>
          <li>{{ record.name }}</li>
          <li>{{ record.vorname }}</li>
          <li>{{ record.year }}</li>
          <li>{{ record.category }}</li>
        </ul>
    </div>
  </div>
</template>
