# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0]

### Changed
- Updated project configuration for Elixir 1.20.x readiness.
- Added ExCoveralls integration (`test_coverage` config and Coveralls CLI preferred environments).
- Updated dev/test dependencies (`ex_doc`, `mock`, and `typedstruct`) and added `meck` and `excoveralls`.
- Tightened test stub callback matching by requiring `%Plug.Conn{}` in `test/paubox/api/email_test.exs`.

## [1.0.0]

### Added
- Completed the core Email API implementation, including `Paubox.API.Email`, `Paubox.Message`, `Paubox.Attachment`, `Paubox.MessageJSON`, and `Paubox.API.SendResponse`.
- Added Message Receipt API support via `Paubox.API.MessageReceipt`.
- Added comprehensive automated tests across core modules and README examples.

### Changed
- Promoted project version to `1.0.0`.
- Expanded and updated project documentation in `README.md`.

### Removed
- Removed duplicate `LICENSE` file (keeping `LICENSE.txt`).

## [0.1.0]

### Added
- Initial release with base foundation.
