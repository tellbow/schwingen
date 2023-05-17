<script setup lang="ts"></script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height"
  >
    <Card class="md:w-9/12 ml-4 mt-4 mr-4">
      <template #title> Schwinger </template>
      <template #content>
        <p>
          Enthält alle aktiven Schwinger aus der
          <a href="https://esv.ch/hkesv/datenbank/">Datenbank des ESV</a> (Stand
          17.05.2023).
        </p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/wrestler')"
        />
      </template>
    </Card>
    <Card class="md:w-9/12 ml-4 mt-2 mr-4">
      <template #title> Schwingfeste </template>
      <template #content>
        <p>Enthält alle Schwingfeste aus den Jahren 2022 & 2023.</p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/places')"
        />
      </template>
    </Card>
  </div>
</template>
