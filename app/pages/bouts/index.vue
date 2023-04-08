<script setup lang="ts">
const pocketbase = usePocketbase();

// you can also fetch all records at once via getFullList
const records = await pocketbase.collection('bouts').getList(1, 50, {
    filter: 'created >= "2022-01-01 00:00:00"',
    expand: 'wrestler1,wrestler2',
});

</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-8">
    <div class="surface-card p-4 shadow-2 border-round md:w-6 lg:w-4">
        <ul v-for="record in records.items">
          <li>{{ record.result }}</li>
          <li>{{ record.expand.wrestler1.name }} {{ record.expand.wrestler1.vorname }}</li>
          <li>{{ record.level }}</li>
          <li>{{ record.points }}</li>
          <li>{{ record.fight_round }}</li>
          <li>{{ record.expand.wrestler2.name }} {{ record.expand.wrestler2.vorname }}</li>
        </ul>
    </div>
  </div>
</template>
