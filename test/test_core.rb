# frozen_string_literal: true

require "test_helper"

class TestCore < Minitest::Test
  class BasicExample
    include Haku::Core

    def call
      "Basic Example"
    end
  end

  class ParamsExample
    include Haku::Core

    def call
      "Hello #{name}!"
    end
  end

  class MagicMethodsExample
    include Haku::Core

    def name
      "Javier"
    end

    def call
      "Hello #{name}! I'm #{params[:name]}"
    end
  end

  class SuccessExample
    include Haku::Core
    on_success :notify_success

    def call
      success! name: "Javier"
    end

    def notify_success; end
  end

  class FailureExample
    include Haku::Core
    on_failure :notify_failure

    def call
      failure! name: "Pedro"
    end

    def notify_failure; end
  end

  def test_basic_execution_result
    assert_equal "Basic Example", BasicExample.call.result
  end

  def test_basic_execution_default_status
    assert_predicate BasicExample.call, :success?
  end

  def test_execution_with_params
    assert_equal "Hello Javier!", ParamsExample.call(name: "Javier").result
  end

  def test_execution_with_param_name_equal_to_method
    assert_equal "Hello Javier! I'm Laura", MagicMethodsExample.call(name: "Laura").result
  end

  def test_success
    result = SuccessExample.call

    assert_predicate result, :success?
    refute_predicate result, :failure?

    assert_equal "Javier", result.name
    assert_nil result.result
  end

  def test_success_callback
    mock = Minitest::Mock.new
    example = SuccessExample.new

    mock.expect :call, true, []

    example.stub(:notify_success, mock) do
      example.run
    end

    assert_mock mock
  end

  def test_failure
    result = FailureExample.call

    assert_predicate result, :failure?
    refute_predicate result, :success?

    assert_equal "Pedro", result.name
    assert_nil result.result
  end

  def test_failure_callback
    mock = Minitest::Mock.new
    example = FailureExample.new

    mock.expect :call, true, []

    example.stub(:notify_failure, mock) do
      example.run
    end

    assert_mock mock
  end
end
