<script setup lang="ts">
const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent,
  )
    ? "mobile"
    : "default";
</script>
<template>
  <div
    class="justify-center flex md:align-items-center align-items-stretch flex-wrap"
  >
    <Card
      class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
      :pt="{
        body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
        content: { class: 'p-1 md:p-2' },
      }"
    >
      <template #title> Verbände </template>
      <template #content>
        <p>Informationen zu den Teilverbänden und dessen Unterverbänden.</p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/associations')"
        />
      </template>
    </Card>
    <Card
      class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
      :pt="{
        body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
        content: { class: 'p-1 md:p-2' },
      }"
    >
      <template #title> Schwinger </template>
      <template #content>
        <p>
          Enthält alle aktiven Schwinger aus der
          <a href="https://esv.ch/hkesv/datenbank/">Datenbank des ESV</a>(Stand
          02.06.2023).
        </p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/wrestler')"
        />
      </template>
    </Card>
    <Card
      class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
      :pt="{
        body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
        content: { class: 'p-1 md:p-2' },
      }"
    >
      <template #title> Schwingfeste </template>
      <template #content>
        <p>Enthält alle Schwingfeste aus den Jahren 2015 - 2024.</p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/places')"
        />
      </template>
    </Card>
    <Card
      v-if="layout === 'default'"
      class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
      :pt="{
        body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
        content: { class: 'p-1 md:p-2' },
      }"
    >
      <template #title> Ranglisten </template>
      <template #content>
        <p>
          Enthält Ränge aus über 2'500 Ranglisten aus den Jahren 2015 - 2024.
        </p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/rankings')"
        />
      </template>
    </Card>
    <Card
      v-if="layout === 'default'"
      class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
      :pt="{
        body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
        content: { class: 'p-1 md:p-2' },
      }"
    >
      <template #title> Kämpfe </template>
      <template #content>
        <p>
          Enthält Kämpfe aus über 2'500 Statistiken aus den Jahren 2015 - 2023.
        </p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/bouts')"
        />
      </template>
    </Card>
    <Card
      class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
      :pt="{
        body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
        content: { class: 'p-1 md:p-2' },
      }"
    >
      <template #title> Statistiken </template>
      <template #content>
        <p>Statistiken über Schwinger</p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/statistics')"
        />
      </template>
    </Card>
  </div>
</template>
