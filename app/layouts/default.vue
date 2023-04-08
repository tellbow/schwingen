<script lang="ts" setup>
const appConfig = useAppConfig()
const pb = usePocketbase()
onMounted(() => {
  const url = window.location.host
  if (!url.includes('localhost')) {
    pb.baseUrl = "https://" + url
  }
})
</script>

<template>
  <Header />
  <div class="layout-empty">
    <slot />
  </div>
  <Footer />
</template>
