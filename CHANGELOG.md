# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/).

## [Unreleased]

### Fixed

- **Correctness**: alphanumeric prerelease identifiers are now compared in true ASCII sort order. The implementation previously relied on MoonBit's built-in `String` ordering, which is length-first and therefore violates SemVer 2.0.0 section 11 (e.g. `1.0.0-alpha` was wrongly ordered *after* `1.0.0-beta`). `cmp_string` now compares code points element by element, independent of the compilation backend.
- **Correctness**: version numbers beyond machine-integer range no longer overflow. Numeric components are now stored as canonical decimal strings and compared by length then lexicographic order. Previously `99999999999999999999999999999999999999.0.0` compared as *less than* `1.0.0`; it now correctly compares as greater. Applies to major/minor/patch and to numeric prerelease identifiers.

### Added

- `Version` now derives `Eq` and `Debug`, so values can be compared and printed directly. Note that `==` is structural equality (build metadata counts), while `compare(a, b) == 0` is SemVer precedence equality (build metadata ignored).
- Parse errors now name the offending fragment (e.g. `invalid character in identifier: alpha_1`) instead of a generic message.
- 9 spec-conformance test groups derived from the SemVer 2.0.0 text: official precedence chain, comparison laws, validity/invalidity matrices, ASCII ordering, build metadata, round-tripping and error messages.
- `is_valid(String) -> Bool` for quick SemVer validation.
- `compare_text(String, String) -> Result[Int, String]` with side-specific errors.
- CLI position arguments backed by `moonbitlang/core/argparse`, with `--help` / `--version`.
- GitHub Actions workflow running type check, tests and demo.
- 9 test groups covering validity helper, error reporting, large numeric identifiers, official precedence chain, comparison laws, ASCII ordering and build metadata (18 tests total).

### Changed

- The demo is now a real CLI with default values instead of hardcoded output.

## [0.1.0] - 2026-11-25

### Added

- Strict SemVer 2.0.0 parser with readable error messages.
- `Version` data type with major/minor/patch, prerelease identifiers and build metadata.
- Precedence comparison following SemVer 2.0.0 rules.
- Canonical `to_string` rendering.
- Executable demo under `src/cmd`.
- 5 test groups covering valid inputs, invalid inputs and precedence edges.
- MIT license, AI usage disclosure and one-page project proposal.
