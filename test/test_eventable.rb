# frozen_string_literal: true

require "test_helper"

class TestEventable < Minitest::Test
  class Event
    def self.create(params)
      new(params)
    end
  end

  class BasicExample
    include Haku::Core
    include Haku::Eventable

    event

    def call
      success! text: "Basic Example"
    end
  end

  class AdvancedExample
    include Haku::Core
    include Haku::Eventable

    event on: :failure, actor: "John Doe", resource: -> { compute_resource }, enabled: true, color: :color,
          name: "advanced_example"

    def call
      failure! text: "Advanced Example"
    end

    def compute_resource
      "Method Resource"
    end

    def color
      :red
    end
  end

  def setup
    Haku.event_model = "TestEventable::Event"
  end

  def test_event_basic
    mock = Minitest::Mock.new

    mock.expect :call, true do |params|
      params[:name] == "test_eventable:basic_example"
    end

    TestEventable::Event.stub(:create, mock) do
      BasicExample.call
    end

    assert_mock mock
  end

  def test_advanced_example
    mock = Minitest::Mock.new

    conditions = {
      name: "advanced_example",
      actor: "John Doe",
      resource: "Method Resource",
      enabled: true,
      color: :red
    }

    mock.expect :call, true do |params|
      conditions.all? { |key, _value| params[key] == conditions[key] }
    end

    TestEventable::Event.stub(:create, mock) do
      AdvancedExample.call
    end

    assert_mock mock
  end

  def teardown
    Haku.event_model = "Event"
  end
end
