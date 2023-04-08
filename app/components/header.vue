<script lang="ts" setup>
import { ref } from "vue";

const items = ref([
    {
        label: 'Home',
        icon: 'pi pi-fw pi-home',
        to: '/'
    },
    {
        label: 'Association',
        to: '/association'
    },
    {
        label: 'Canton',
        to: '/canton'
    },
    {
        label: 'Club',
        to: '/club'
    },
    {
        label: 'Wrestler',
        to: '/wrestler'
    },
    {
        label: 'Places',
        to: '/places'
    },
    {
        label: 'Bouts',
        to: '/bouts'
    },
    {
        label: 'Account',
        to: '/account'
    }
]);

</script>

<template>
    <TabMenu :model="items" />
</template>
