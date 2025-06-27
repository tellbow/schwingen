export const useLayout = () => {
  const layout = computed(() => {
    if (import.meta.client) {
      return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
        navigator.userAgent,
      )
        ? "mobile"
        : "default";
    }
    return "default";
  });

  const isMobile = computed(() => layout.value === "mobile");
  const isDesktop = computed(() => layout.value === "default");

  const numberOfRows = computed(() => (isMobile.value ? 10 : 15));
  const numberOfPages = computed(() => (isMobile.value ? 3 : 4));

  return {
    layout,
    isMobile,
    isDesktop,
    numberOfRows,
    numberOfPages,
  };
};
