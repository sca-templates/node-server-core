import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['test/**/*.test.ts'],
    // No test file exists until the first module does. Without this the suite
    // exits 1 with "No test files found" and CI fails on an empty repository.
    passWithNoTests: true,
    coverage: {
      provider: 'v8',
      include: ['src/**/*.ts'],
      // No thresholds yet: `src/index.ts` is an empty barrel, so any threshold
      // above 0 would fail the build. Set them together with the first module.
      reporter: ['text', 'lcov'],
    },
  },
});
