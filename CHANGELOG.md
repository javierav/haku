## [Unreleased]

## [1.5.0] - 2023-01-25
* **Breaking**: Simplify Haku::Eventable module

## [1.4.0] - 2022-09-19
- Improve `Haku::Eventable` module to support more data sources for event properties
- Add `Haku::Delayable` module to execute service object in background
- Improve README
- **Breaking**: Require `activesupport` >= 6.1
- **Breaking**: Require Ruby >= 2.7
- Fix CI test invocation

## [1.3.1] - 2022-04-27
- Fix Haku::Controller

## [1.3.0] - 2022-04-27
- Fix accessors creation
- **Breaking**: Remove Rails railtie. Use `include Haku::Controller` in controllers instead.

## [1.2.1] - 2022-04-20
- Fix accessors creation when result is plain array

## [1.2.0] - 2022-04-20
- Refactor how response is created on finish

## [1.1.0] - 2022-04-19
- Allow to configure Haku using block
- Add Eventable module to fire events
- Add persist_resource to Resourceable
- Allow to declare inputs instead of create automatically
- Avoid using run to execute code. Using call is better
- Improve README
- Use Appraisal to test against multiple versions of some gems

## [1.0.0] - 2022-04-11
- Initial release
