import PocketBase from "pocketbase";

const runtimeConfig = useRuntimeConfig();
const pb = new PocketBase(runtimeConfig.public.baseUrl);

export const usePocketbase = () => {
  return pb;
};
