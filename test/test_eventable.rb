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

    event on: :failure, other: "Class Method", signature: -> { compute_signature }, enabled: true, color: :color,
          name: "advanced_example"

    def call
      @event_actor = "Event Instance Variable Actor"
      @actor = "Instance Variable Actor"
      @resource = "Instance Variable Resource"
      @target = "Instance Variable Target"

      failure! text: "Advanced Example"
    end

    def event_actor
      "Event Method Actor"
    end

    def event_resource
      "Event Method Resource"
    end

    def resource
      "Method Resource"
    end

    def target
      "Method Target"
    end

    def context
      "Method Context"
    end

    def compute_signature
      "Signature"
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
      actor: "Event Instance Variable Actor",
      resource: "Event Method Resource",
      target: "Instance Variable Target",
      context: "Method Context",
      other: "Class Method",
      signature: "Signature",
      enabled: true,
      color: :red
    }

    mock.expect :call, true do |params|
      params.all? { |key, _value| params[key] == conditions[key] }
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
