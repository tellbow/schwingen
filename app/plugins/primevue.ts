import PrimeVue from "primevue/config";
import Button from "primevue/button";
import Checkbox from "primevue/checkbox";
import InputText from "primevue/inputtext";
import Card from "primevue/card";
import Toast from "primevue/toast";
import TabMenu from "primevue/tabmenu";
import Dropdown from "primevue/dropdown";
import DataTable from "primevue/datatable";
import DataView from "primevue/dataview";
import Accordion from "primevue/accordion";
import AccordionTab from "primevue/accordiontab";
import Column from "primevue/column";
import ProgressSpinner from "primevue/progressspinner";
import Chart from "primevue/chart";
import ScrollTop from "primevue/scrolltop";
import Badge from "primevue/badge";
import OverlayPanel from "primevue/overlaypanel";
import ConfirmationService from "primevue/confirmationservice";
import ToastService from "primevue/toastservice";

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.component("Button", Button);
  nuxtApp.vueApp.component("Checkbox", Checkbox);
  nuxtApp.vueApp.component("InputText", InputText);
  nuxtApp.vueApp.component("Card", Card);
  nuxtApp.vueApp.component("Toast", Toast);
  nuxtApp.vueApp.component("TabMenu", TabMenu);
  nuxtApp.vueApp.component("Dropdown", Dropdown);
  nuxtApp.vueApp.component("DataTable", DataTable);
  nuxtApp.vueApp.component("DataView", DataView);
  nuxtApp.vueApp.component("Accordion", Accordion);
  nuxtApp.vueApp.component("AccordionTab", AccordionTab);
  nuxtApp.vueApp.component("Column", Column);
  nuxtApp.vueApp.component("ScrollTop", ScrollTop);
  nuxtApp.vueApp.component("ProgressSpinner", ProgressSpinner);
  nuxtApp.vueApp.component("Chart", Chart);
  nuxtApp.vueApp.component("Badge", Badge);
  nuxtApp.vueApp.component("OverlayPanel", OverlayPanel);

  nuxtApp.vueApp.use(PrimeVue, {
    locale: {
      apply: "Anwenden",
      clear: "Löschen",
      contain: "Enthält",
      equals: "Gleich",
      noFilter: "Kein Filter",
    },
    ripple: true,
  });
  nuxtApp.vueApp.use(ToastService);
  nuxtApp.vueApp.use(ConfirmationService);
});
