<script setup lang="ts">
const pocketbase = usePocketbase();

const associationData = ref();
const cantonData = ref();
const clubData = ref();
const loadingAssociation = ref(true);

onMounted(async () => {
  await pocketbase
    .collection("association")
    .getFullList(10 /* batch size */, {
      sort: "name,-created",
    })
    .then((data) => {
      associationData.value = data;
      loadingAssociation.value = false;
    });
});

const onTabOpen = async (event: { index: string | number }) => {
  await pocketbase
    .collection("canton")
    .getFullList(50 /* batch size */, {
      sort: "name,-created",
      filter:
        'association.id = "' + associationData.value[event.index].id + '"',
    })
    .then((data) => {
      cantonData.value = data;
    });
};

const onSubTabOpen = async (event: { index: string | number }) => {
  await pocketbase
    .collection("club")
    .getFullList(200 /* batch size */, {
      sort: "name,-created",
      filter: 'canton.id = "' + cantonData.value[event.index].id + '"',
    })
    .then((data) => {
      clubData.value = data;
    });
};
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
  >
    <ProgressSpinner v-if="loadingAssociation" />
    <Accordion
      v-else
      lazy
      class="w-12 sm:w-10 md:w-8 lg:w-6 xl:w-4"
      @tab-open="onTabOpen($event)"
    >
      <AccordionTab
        v-for="association in associationData"
        :key="association.id"
        :header="association.abbreviation"
      >
        <Accordion lazy @tab-open="onSubTabOpen($event)">
          <AccordionTab
            v-for="canton in cantonData"
            :key="canton.id"
            :header="canton.name"
          >
            <ul>
              <li v-for="value in clubData" :key="value.id">
                {{ value.name }}
              </li>
            </ul>
          </AccordionTab>
        </Accordion>
      </AccordionTab>
    </Accordion>
  </div>
</template>
