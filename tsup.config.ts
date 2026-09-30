import { defineConfig } from 'tsup';

export default defineConfig({
  // Every file under `src/` becomes its own entry, so adding a module never
  // requires touching this file. Each entry also needs a matching subpath in
  // the `exports` map in package.json.
  entry: ['src/**/*.ts'],
  format: ['esm'],
  dts: true,
  clean: true,
  target: 'node22',
});
