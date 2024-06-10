import withNuxt from './.nuxt/eslint.config.mjs'

export default withNuxt(
  {
    files: ['*.vue', '*.ts'],
    ignores: ["pb_migrations/*"],
    rules: {
      'vue/multi-word-component-names': 'off'
    }
  }
)
