<template>
    <Button label="Home" icon="pi pi-home" class="w-half mt-3" @click="navigateTo('/')"></Button>
    <Button label="Association" class="w-half mt-3" @click="navigateTo('/association')"></Button>
    <Button label="Canton" class="w-half mt-3" @click="navigateTo('/canton')"></Button>
    <Button label="Club" class="w-half mt-3" @click="navigateTo('/club')"></Button>
    <Button label="Wrestler" class="w-half mt-3" @click="navigateTo('/wrestler')"></Button>
    <Button label="Places" class="w-half mt-3" @click="navigateTo('/places')"></Button>
    <Button label="Bouts" class="w-half mt-3" @click="navigateTo('/bouts')"></Button>
</template>