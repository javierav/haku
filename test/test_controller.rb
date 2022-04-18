# frozen_string_literal: true

require "test_helper"
require "haku/controller"

class TestController < Minitest::Test
  class ExampleService
    include Haku::Core

    input :name, :current_user

    def call
      success! text: formated_text
    end

    def formated_text
      text = ["Hello #{name}"]
      text << ", I'm #{current_user}" if current_user
      text.join
    end
  end

  class ControllerWithoutCurrentUser
    include Haku::Controller

    def call
      execute ExampleService, name: "Javier"
    end
  end

  class ControllerWithCurrentUser
    include Haku::Controller

    def call
      execute ExampleService, name: "Javier"
    end

    def current_user
      "Laura"
    end
  end

  class ControllerWithOverwritedCurrentUser
    include Haku::Controller

    def call
      execute ExampleService, name: "Javier", current_user: "Pablo"
    end

    def current_user
      "Laura"
    end
  end

  def test_execution_without_current_user
    controller = ControllerWithoutCurrentUser.new
    controller.call

    assert_equal "Hello Javier", controller.execution.text
  end

  def test_execution_with_current_user
    controller = ControllerWithCurrentUser.new
    controller.call

    assert_equal "Hello Javier, I'm Laura", controller.execution.text
  end

  def test_execution_with_overwrited_current_user
    controller = ControllerWithOverwritedCurrentUser.new
    controller.call

    assert_equal "Hello Javier, I'm Pablo", controller.execution.text
  end
end
