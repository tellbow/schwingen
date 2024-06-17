import withNuxt from "./.nuxt/eslint.config.mjs";

export default withNuxt({
  files: ["*.vue", "*.ts"],
  ignores: ["pb_migrationss/"],
})
  .override("nuxt/vue/rules", {
    rules: {
      "vue/multi-word-component-names": "off",
      "vue/html-self-closing": "off",
    },
  })
  .override("nuxt/typescript/rules", {
    rules: {
      "@typescript-eslint/no-explicit-any": "off",
    },
  });
