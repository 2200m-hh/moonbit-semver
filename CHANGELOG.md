# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/).

## [Unreleased]

### Added

- `is_valid(String) -> Bool` for quick SemVer validation.
- `compare_text(String, String) -> Result[Int, String]` with side-specific errors.
- CLI position arguments backed by `moonbitlang/core/argparse`, with `--help` / `--version`.
- GitHub Actions workflow running type check, tests and demo.
- 3 extra test groups covering validity helper, error reporting and large numeric identifiers (8 tests total).

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
