# Contributing

Use tabs where supported. YAML uses spaces; Dart uses the standard Dart formatter.
Run the checks listed in README.md before opening a pull request. Keep the runtime
dependency-free and keep UI formatting outside the numeric API.

## Cross-language behavior

The compaction JSON fixtures in `test/fixtures/compaction.json` are duplicated
in the companion repository. Keep them identical when changing numeric behavior.
Tests cover signs, midpoint boundaries, zero, metadata, precision and promotions.

## Release setup

An owner must publish the first version from an authenticated account. Then in
pub.dev's package Admin tab, enable automated publishing for repository
`core-laboratories/compact_money`, with tag pattern `{{version}}`.
The release workflow delegates publishing to Dart's official reusable OIDC
workflow. See [pub.dev automated publishing](https://dart.dev/tools/pub/automated-publishing).


## Releasing a version

1. Update `pubspec.yaml` and CHANGELOG.md.
2. Run all README checks, including the publication dry run.
3. Commit and push the reviewed changes.
4. Create and push a stable tag matching the manifest, for example `0.0.2`.

The `release.yml` workflow runs CI before publication and rejects a mismatched
version tag. Only stable `MAJOR.MINOR.PATCH` tags are supported. Pushing such a tag
publishes the package after registry setup; creating a GitHub Release is optional.
The initial 0.0.1 bootstrap publication is a manual owner step, so start automated
tags at the next version. Do not reuse an already-published version.

Registry account setup and actual publication are separate from local package
creation. No credentials belong in this repository.
