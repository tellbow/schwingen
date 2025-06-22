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
          19.06.2025).
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
        <p>Enthält alle Schwingfeste der Aktiven aus den Jahren 2015 - 2025.</p>
        <Button
          label="Anzeigen"
          class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
          @click="navigateTo('/places')"
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
