/**
 * Strict Conventional Commits, mirroring the org convention in
 * `0.Project_info/commit_en.md` (local reference, not committed).
 *
 * The rules are spelled out instead of relying on the upstream preset alone:
 * if `@commitlint/config-conventional` ever widens a list, this repo does not
 * silently follow.
 */
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // The 11 types the convention allows, in its order.
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'perf',
        'build',
        'ci',
        'docs',
        'refactor',
        'style',
        'test',
        'chore',
        'revert',
      ],
    ],
    'type-case': [2, 'always', 'lower-case'],

    // Scopes are deliberately not an enum: the convention lists them as
    // "suggested, use if applicable", and a closed set would reject legitimate
    // scopes such as `eslint` or `npm`.
    'scope-case': [2, 'always', 'lower-case'],

    'subject-empty': [2, 'never'],
    // The convention asks for a lowercase subject. commitlint can reject the
    // capitalisation styles it knows about, but it cannot reject a capital in
    // the middle of an otherwise lowercase subject — that limit is inherent to
    // the rule set, not to this config.
    'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72],
    'body-max-line-length': [2, 'always', 100],
    'footer-max-line-length': [2, 'always', 100],
  },
};
