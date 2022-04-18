# frozen_string_literal: true

require "test_helper"

class TestHaku < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Haku::VERSION
  end

  def test_controller_base_enabled
    assert Haku.enable_in_action_controller_base
  end

  def test_controller_api_enabled
    assert Haku.enable_in_action_controller_api
  end

  def test_configuration
    current_event_model = Haku.event_model

    Haku.configure do |config|
      config.event_model = "TestEvent"
    end

    assert_equal "TestEvent", Haku.event_model

    Haku.event_model = current_event_model
  end
end
