<script setup lang="ts">
const pocketbase = usePocketbase();

const associationData = ref();
const cantonData = ref();
const clubData = ref();
const loadingAssociation = ref(true);

onMounted(async () => {
  await pocketbase
    .collection("wrestlersByAssociation")
    .getFullList(10 /* batch size */, {
      sort: "name",
      fields: "id,name,abbreviation,wrestlerAmount",
    })
    .then((data) => {
      associationData.value = data;
      loadingAssociation.value = false;
    });
});

const onTabOpen = async (event: { index: string | number }) => {
  await pocketbase
    .collection("wrestlersByCanton")
    .getFullList(50 /* batch size */, {
      sort: "name",
      filter:
        'association.id = "' + associationData.value[event.index].id + '"',
      fields: "id,name,association,wrestlerAmount",
    })
    .then((data) => {
      cantonData.value = data;
    });
};

const onSubTabOpen = async (event: { index: string | number }) => {
  await pocketbase
    .collection("wrestlersByClub")
    .getFullList(200 /* batch size */, {
      sort: "name",
      filter: 'canton.id = "' + cantonData.value[event.index].id + '"',
      fields: "id,name,canton,wrestlerAmount",
    })
    .then((data) => {
      clubData.value = data;
    });
};
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-3 md:mt-6"
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
        :header="
          association.abbreviation +
          ' (' +
          association.wrestlerAmount +
          ' Schwinger)'
        "
      >
        <Accordion lazy @tab-open="onSubTabOpen($event)">
          <AccordionTab
            v-for="canton in cantonData"
            :key="canton.id"
            :header="canton.name + ' (' + canton.wrestlerAmount + ' Schwinger)'"
          >
            <ul>
              <li v-for="value in clubData" :key="value.id">
                <NuxtLink
                  :to="'/clubs/' + value.id"
                  class="cursor-pointer hover:bg-gray-200"
                  >{{ value.name }} ({{
                    value.wrestlerAmount
                  }}
                  Schwinger)</NuxtLink
                >
              </li>
            </ul>
          </AccordionTab>
        </Accordion>
      </AccordionTab>
    </Accordion>
  </div>
</template>
