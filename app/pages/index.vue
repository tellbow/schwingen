<script setup lang="ts">
const pocketbase = usePocketbase();

const user = pocketbase.authStore.model

function logout() {
  pocketbase.authStore.clear()
  navigateTo('/auth/login')
}

</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-8">
    <Card>
      <template #title> Schwinger </template>
      <template #content>
          <p>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Inventore sed consequuntur error repudiandae numquam deserunt quisquam repellat libero asperiores earum nam nobis, culpa ratione quam perferendis esse, cupiditate neque
              quas!
          </p>
          <Button v-if="user" label="Anzeigen" class="w-half mt-3 ml-3" @click="navigateTo('/wrestler')"></Button>
      </template>
    </Card>
    <Card>
      <template #title> Schwingfeste </template>
      <template #content>
          <p>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Inventore sed consequuntur error repudiandae numquam deserunt quisquam repellat libero asperiores earum nam nobis, culpa ratione quam perferendis esse, cupiditate neque
              quas!
          </p>
          <Button v-if="user" label="Anzeigen" class="w-half mt-3 ml-3" @click="navigateTo('/places')"></Button>
      </template>
    </Card>
  </div>
</template>
