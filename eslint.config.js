// @ts-check
import js from '@eslint/js';
import prettier from 'eslint-config-prettier';
import globals from 'globals';
import security from 'eslint-plugin-security';
import sonarjs from 'eslint-plugin-sonarjs';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  {
    // `dist` is build output. The root `*.config.js` files are JavaScript
    // outside the tsconfig project, so the type-aware rules have no program to
    // read for them; the trade-off is that they get no lint coverage at all,
    // which costs nothing here because they are declarative data.
    ignores: ['dist/**', '*.config.js', '*.config.mjs'],
  },
  js.configs.recommended,
  tseslint.configs.strictTypeChecked,
  sonarjs.configs.recommended,
  security.configs.recommended,
  // Must stay last: it switches off every rule that would fight Prettier.
  prettier,
  {
    languageOptions: {
      globals: {
        ...globals.node,
      },
      sourceType: 'module',
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // This package is a shared core consumed by other services, so an
      // unchecked dynamic key access is a real bug source, not a style
      // preference. Kept on despite the noise it generates.
      'security/detect-object-injection': 'error',
    },
  },
);
