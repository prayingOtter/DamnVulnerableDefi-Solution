module.exports = {
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,
  singleQuote: true,
  semi: true,
  trailingComma: 'all',
  arrowParens: 'avoid',
  overrides: [
    {
      files: '*.sol',
      options: {
        tabWidth: 4,
        singleQuote: false,
        trailingComma: 'none',
      },
    },
  ],
};
