import type { Ref } from "vue";

export interface DataLoaderOptions<T> {
  onSuccess?: (data: T) => void;
  onError?: (error: Error) => void;
  defaultValue?: T;
}

export const useDataLoader = <T>(options: DataLoaderOptions<T> = {}) => {
  const data = ref<T | null>(options.defaultValue || null) as Ref<T | null>;
  const loading = ref(false);
  const error = ref<Error | null>(null);

  const execute = async (loader: () => Promise<T>): Promise<T | null> => {
    try {
      loading.value = true;
      error.value = null;

      const result = await loader();
      data.value = result;

      if (options.onSuccess) {
        options.onSuccess(result);
      }

      return result;
    } catch (err) {
      const errorObj = err instanceof Error ? err : new Error(String(err));
      error.value = errorObj;

      if (options.onError) {
        options.onError(errorObj);
      } else {
        console.error("Data loading error:", errorObj);
      }

      return null;
    } finally {
      loading.value = false;
    }
  };

  const reset = () => {
    data.value = options.defaultValue || null;
    loading.value = false;
    error.value = null;
  };

  return {
    data: readonly(data),
    loading: readonly(loading),
    error: readonly(error),
    execute,
    reset,
  };
};
