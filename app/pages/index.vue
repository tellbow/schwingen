<script setup lang="ts"></script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height"
  >
    <Card class="w-9/12 mt-4">
      <template #title> Schwinger </template>
      <template #content>
        <p>
          Enthält alle aktiven Schwinger aus der
          <a href="https://esv.ch/hkesv/datenbank/">Datenbank des ESV</a> (Stand
          11.02.2023).
        </p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 ml-3"
          @click="navigateTo('/wrestler')"
        />
      </template>
    </Card>
    <Card class="w-9/12 mt-4">
      <template #title> Schwingfeste </template>
      <template #content>
        <p>Enthält alle Schwingfeste der Aktivschwinger aus dem Jahr 2022.</p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 ml-3"
          @click="navigateTo('/places')"
        />
      </template>
    </Card>
  </div>
</template>
