<script setup lang="ts">
const pocketbase = usePocketbase();

const route = useRoute();

const placeData = ref();
const rankingsData = ref();
const loadingPlace = ref(true);
const loadingRankings = ref(true);
const loadingBouts = ref(true);
const expandedRows = ref();

onMounted(async () => {
  await pocketbase
    .collection("places")
    .getFirstListItem('id="' + route.params.id + '"', { expand: "placeType" })
    .then((data) => {
      data.year = data.year.split("-")[0];
      placeData.value = data;
      loadingPlace.value = false;
    });
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      filter: 'place.id = "' + route.params.id + '"',
      expand: "place,wrestler",
      sort: "rank, rank2, -created",
      fields:
        "id,rank,rank2,points,final,result,wreath,status,expand.place.id,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname",
    })
    .then((data) => {
      rankingsData.value = data.sort(compareByRank);
      loadingRankings.value = false;
    });
});

const loadLazySubData = (wrestlerId: string, placeId: string) => {
  loadingBouts.value = true;
  pocketbase
    .collection("bouts")
    .getList(1, 10, {
      expand: "opponent,opponent.status",
      filter:
        "wrestler.id = '" + wrestlerId + "' && place.id = '" + placeId + "'",
      sort: "fight_round,-created",
      fields:
        "id,result,points,fight_round,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.opponent.expand.status.status",
    })
    .then((data: { items: any }) => {
      rankingsData.value.forEach((item: any) => {
        if (
          item.expand.wrestler.id === wrestlerId &&
          item.expand.place.id === placeId
        ) {
          item.bouts = data.items;
        }
      });
      loadingBouts.value = false;
    });
};

// Custom comparator function to sort by rank
const compareByRank = (a: any, b: any) => {
  // Extract numerical and alphabetical components
  const numA = parseInt(a.rank);
  const numB = parseInt(b.rank);
  const alphaA = a.rank2;
  const alphaB = b.rank2;

  // Compare numerical components
  if (numA !== numB) {
    return numA - numB;
  }

  // If numerical components are equal, compare alphabetical components
  return alphaA.localeCompare(alphaB);
};

const onRowExpand = (event: {
  data: {
    expand: {
      wrestler: { id: string };
      place: { id: string };
    };
  };
}) => {
  loadLazySubData(event.data.expand.wrestler.id, route.params.id.toString());
};

const onRowCollapse = (event: {
  data: {
    id: string;
  };
}) => {
  const objIndex = rankingsData.value.findIndex(
    (obj: { id: string }) => obj.id === event.data.id,
  );
  rankingsData.value[objIndex].bouts = [];
};
</script>
<template>
  <div>
    <ProgressSpinner v-if="loadingPlace" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-11/12 md:w-9/12">
        <template #title> Schwingfest: {{ placeData.name }} </template>
        <template #content>
          <p>Ort: {{ placeData.location }}</p>
          <p>Jahr: {{ placeData.year }}</p>
          <p v-if="placeData.expand.placeType">
            Typ: {{ placeData.expand.placeType.type }}
          </p>
        </template>
      </Card>
    </div>
    <ProgressSpinner v-if="loadingRankings" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-11/12 md:w-9/12">
        <template #title> Rangliste Neu</template>
        <template #content>
          <DataTable
            v-model:expanded-rows="expandedRows"
            :value="rankingsData"
            column-resize-mode="fit"
            show-gridlines
            table-style="min-width: 50rem"
            size="small"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
            :row-hover="true"
            @row-expand="onRowExpand($event)"
            @row-collapse="onRowCollapse($event)"
          >
            <template #empty> Keine Ranglisten gefunden. </template>
            <template #loading>
              Ranglisten werden geladen. Bitte warten.
            </template>
            <Column expander style="width: 4rem" />
            <Column
              field="rank"
              header="Rang"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.rank }}{{ data.rank2 }}
              </template>
            </Column>
            <Column
              field="points"
              header="Punkte"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.points }}
              </template>
            </Column>
            <Column
              field="result"
              header="Resultat"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.result }}
              </template>
            </Column>
            <Column
              field="wrestler"
              header="Schwinger"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.expand.wrestler.name }}
                {{ data.expand.wrestler.vorname }}
              </template>
            </Column>
            <Column
              field="final"
              header="Schlussgang"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                <Icon v-if="data.final" name="gis:flag-finish" />
              </template>
            </Column>
            <Column
              field="wreath_accident"
              header="Kranz / Unfall"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                <Icon v-if="data.wreath" name="mingcute:wreath-fill" />
                <Icon
                  v-if="data.status === 'Unfall'"
                  name="game-icons:arm-bandage"
                />
              </template>
            </Column>
            <template #expansion="data">
              <div class="p-1">
                <DataTable :value="data.data.bouts">
                  <Column field="result" header="R"></Column>
                  <Column field="points" header="P"></Column>
                  <Column field="fight_round" header="G"></Column>
                  <Column field="expand.opponent.name" header="Name"></Column>
                  <Column
                    field="expand.opponent.vorname"
                    header="Vorname"
                  ></Column>
                  <Column
                    field="expand.opponent.expand.status.status"
                    header="Status"
                  ></Column>
                </DataTable>
              </div>
            </template>
          </DataTable>
        </template>
      </Card>
    </div>
  </div>
</template>
