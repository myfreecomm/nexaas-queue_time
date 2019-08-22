# Changelog

All notable changes to this project will be documented in this file.

## [0.4.0] - 2019-08-22

### Added

- Collect Sidekiq `queue.latency` [(#1)](https://github.com/myfreecomm/nexaas-queue_time/pull/1)

## [0.3.0] - 2019-07-01

### Added

- Document middleware class
- Test for header pattern before calculating `queue_time`

### Changed

- Do not calculate `queue_time` if header is not present

### Fixed

- Use `String =~` instead of `String#match?` due to Ruby 2.3

## [0.2.0] - 2019-06-28

### Fixed

- Extract timestamp from the header

## [0.1.0] - 2019-06-28

### Added

- Initial implementation of the gem


[0.2.0]: https://github.com/myfreecomm/nexaas-queue_time/compare/v0.1.0...v0.2.0/
[0.3.0]: https://github.com/myfreecomm/nexaas-queue_time/compare/v0.2.0...v0.3.0/
[0.4.0]: https://github.com/myfreecomm/nexaas-queue_time/compare/v0.3.0...v0.4.0/
