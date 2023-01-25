# Haku

![CI](https://github.com/javierav/haku/workflows/CI/badge.svg)

A library for build simple service objects.

## Status

> :warning: **This project is still experimental, use with caution!**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'haku'
```

And then execute:

```shell
bundle install
```

## Usage

**Haku** is made up of four modules that add functionality to our service objects:

* `Haku::Core`
* `Haku::Delayable`
* `Haku::Eventable`
* `Haku::Resourceable`

Additionally, it's available the `Haku::Controller` module for use in ours Rails controllers.

### Haku::Core

```ruby
class Users::Update
  include Haku::Core

  input :user, :attributes
  on_success :send_email

  def call
    if user.update(attributes)
      success! resource: user
    else
      failure! resource: user, errors: user.errors
    end
  end

  private

  def send_email
    UserMailer.with(user: user).update.deliver_later
  end
end

response = Users::Update.call(user: User.first, attributes: { name: "Javier" })

response.success? # => true
response.result # => { resource: <User id="1" ...> }
response.resource # => <User id="1" ...>
```

As you can see, if the payload passed to `success!` or `failure!` is a hash, each key of the hash can be accessed
directly in response object.

### Haku::Delayable

#### Basic example

```ruby
class Users::ComputeHours
  include Haku::Core
  include Haku::Delayable

  input :user

  def call
    # compute expensive data for user
  end
end

Users::ComputeHours.delayed.call(user: User.first)
```

Use `delayed.call` instead of `call` for execute service object in background using `ActiveJob` job.

#### Customize job

```ruby
Users::ComputeHours.delayed(job: OtherJob).call(user: User.first)
```

#### Customize job options

```ruby
Users::ComputeHours.delayed(job: OtherJob, queue: :low, priority: 2).call(user: User.first)
```

You can pass the same options allowed by ActiveJob
[set](https://api.rubyonrails.org/v7.0.4/classes/ActiveJob/Core/ClassMethods.html#method-i-set) method:


### Haku::Eventable

#### Basic example

```ruby
class Users::Update
  include Haku::Core
  include Haku::Eventable

  input :user, :attributes
  event resource: :user

  def call
    success! resource: user
  end
end

Users::Update.call(user: User.first, attributes: { name: "Javier" })

# => call Event.create(name: "user:update", resource: User.first)
```

The `name` attribute are calculated using the custom proc from `event_name` config option. You can change it with

```ruby
event name: 'custom:name', resource: :user
```

#### Properties passed to event model

Properties that should be passed to event model are defined in `event_properties` config option and by
default are `actor` `resource`, `target` and `context`.

1. Append base properties. For each property defined in `event_properties` config option, it will try to:
   1. If defined a instance variable `@event_<property>`, uses the instance variable value to get the value of property.
   2. If respond_to method called `event_<property>`, method is used to get the value of property.
   3. If defined a instance variable `@<property>`, uses the instance variable value to get the value of property.
   4. If respond_to method called `<property>`, method is used to get the value of property.
   5. In other case, the property is not appended.
2. Append properties defined in `event` class method. Overwrites previous values. For each property, will try to:
   1. If is a block, it is called to get the value of property.
   2. If is a symbol:
      1. If defined a instance variable `@<property>`, uses the instance variable value to get the value of property.
      2. If respond_to `<property>`, method is used to get the value of property.
   3. In other case, uses the raw value.


### Haku::Resourceable

```ruby
class Users::Update
  include Haku::Core
  include Haku::Resourceable

  input :user, :attributes
  on_success :send_email

  def call
    update_resource(user, attributes)
  end

  private

  def send_email
    UserMailer.with(user: user).update.deliver_later
  end
end
```


### Haku::Controller

```ruby
class UsersController < ApplicationController
  include Haku::Controller

  before_action :find_user

  def update
    execute Users::Update, user: @user, attributes: update_params

    if execution.success?
      redirect_to user_path(execution.resource)
    else
      render :edit, errors: execution.errors
    end
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def update_params
    params.require(:user).permit(:first_name, :last_name)
  end
end
```


### Using parent class

```ruby
class ApplicationAction
  include Haku::Core
  include Haku::Resourceable
  include Haku::Eventable
end

class Users::Update < ApplicationAction
end
```


## Configure

### Example

```ruby
# config/initializers/haku.rb

Haku.configure do |config|
  config.event_model = "EventLog"
end
```

### Allowed options

| Config                    | Description                                           | Default value                                           |
|:--------------------------|:------------------------------------------------------|:--------------------------------------------------------|
| `event_model`             | Name of the model used for create events              | `Event`                                                 |
| `event_properties`        | List of attributes passed from service to event model | `%i[actor resource target context]`                     |
| `event_property_for_name` | Property used for name in event model                 | `:name`                                                 |
| `event_name`              | String or Proc to determine the event name            | Custom Proc. Example: `user:create` for `Users::Create` |
| `job_queue`               | String or Symbol with queue name                      | `default`                                               |


## Resourceable

This module include helpers to works with *ActiveRecord* compatible model resources, invoking `success!` or `failure!`
based in the result of the performed operation.

### create_resource

Call to `create` or `<singleton>_create` method of the `parent` object passing the `attributes` and storing
the result object in the `ivar` instance variable. Invoke `success!` if the model is persisted or `failure!` in other
case.

| parameter    | type     | description                                                      |
|--------------|----------|------------------------------------------------------------------|
| `parent`     | `Object` | Parent object where new resource will be created                 |
| `attributes` | `Hash`   | Attributes for create                                            |
| `ivar`       | `Symbol` | Name of the instance variable used to access to the new resource |
| `options`    | `Hash`   | Options hash                                                     |

#### options

| parameter   | type     | description                                                          |
|-------------|----------|----------------------------------------------------------------------|
| `singleton` | `Symbol` | If the resource should be created using `<singleton>_create` suffix. |

### update_resource

Call to `update` method of the `resource` object passing `attributes`to it. Invoke `success!` if the model is updated or
`failure!` in other case.

| parameter    | type     | description            |
|--------------|----------|------------------------|
| `resource`   | `Object` | Resource to be updated |
| `attributes` | `Hash`   | Attributes to update   |

### destroy_resource

Call to `destroy` method of the `resource`. Invoke `success!` if the model is destroyed or `failure!` in other case.

| parameter    | type     | description              |
|--------------|----------|--------------------------|
| `resource`   | `Object` | Resource to be destroyed |

### persist_resource

| parameter      | type     | description                                 |
|----------------|----------|---------------------------------------------|
| `resource`     | `Object` | Resource to be destroyed                    |
| `save_options` | `Hash`   | Options passed to `save` method of resource |

For more info please view the [source code](lib/haku/resourceable.rb) of the module.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome, please follow
[Github Flow](https://docs.github.com/en/get-started/quickstart/github-flow).


## Code of Conduct

Everyone interacting in the Haku project's codebases, issue trackers, chat rooms and mailing lists is expected to
follow the [code of conduct](https://github.com/javierav/haku/blob/development/CODE_OF_CONDUCT.md).


## License

Copyright © 2022-2023 Javier Aranda. Released under the terms of the [MIT license](LICENSE).
