<script setup lang="ts">
const pocketbase = usePocketbase();

const cantonData = ref();
const clubData = ref();
const loadingAssociation = ref(true);
const loadingCanton = ref(true);
const loadingClub = ref(true);

const nodes = ref(null);
const loading = ref(false);

onMounted(async () => {
  loading.value = true;

  setTimeout(() => {
    nodes.value = initateNodes();
    //nodes.value = associationData();
    loading.value = false;
  }, 2000);
  // await pocketbase
  //   .collection("association")
  //   .getFullList(200 /* batch size */, {
  //     sort: "name,-created",
  //   })
  //   .then((data) => {
  //     associationData.value = data;
  //     loadingAssociation.value = false;
  //   });
  // await pocketbase
  //   .collection("canton")
  //   .getFullList(200 /* batch size */, {
  //     sort: "name,-created",
  //   })
  //   .then((data) => {
  //     cantonData.value = data;
  //     loadingCanton.value = false;
  //   });
  // await pocketbase
  //   .collection("club")
  //   .getFullList(200 /* batch size */, {
  //     sort: "name,-created",
  //   })
  //   .then((data) => {
  //     clubData.value = data;
  //     loadingClub.value = false;
  //   });
});

const onNodeExpand = (node: { children: any; key: string; label: string }) => {
  if (!node.children) {
    loading.value = true;

    setTimeout(() => {
      const _node = { ...node };

      _node.children = [];

      for (let i = 0; i < 3; i++) {
        _node.children.push({
          key: node.key + "-" + i,
          label: "Lazy " + node.label + "-" + i,
        });
      }

      const _nodes = { ...nodes.value };
      _nodes[parseInt(node.key, 10)] = _node;

      nodes.value = _nodes;
      loading.value = false;
    }, 500);
  }
};

const associationData = () => {
  return pocketbase
    .collection("association")
    .getFullList(200 /* batch size */, {
      sort: "name,-created",
    })
    .then((data) => {
      data.map((record) => {
        return {
          key: record.id,
          label: record.name,
          data: record.name + " Folder",
          icon: "pi pi-fw pi-inbox",
          children: [],
        };
      });
      return data;
    });
};

const initateNodes = () => {
  return [
    {
      key: "0",
      label: "Node 0",
      leaf: false,
    },
    {
      key: "1",
      label: "Node 1",
      leaf: false,
    },
    {
      key: "2",
      label: "Node 2",
      leaf: false,
    },
  ];
};
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
  >
    <!-- ToDo: https://primevue.org/tree/#lazy -->
    <Tree
      :value="nodes"
      :loading="loading"
      class="w-full md:w-30rem"
      @node-expand="onNodeExpand"
    ></Tree>
  </div>
</template>
