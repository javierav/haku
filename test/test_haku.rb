# frozen_string_literal: true

require "test_helper"

class TestHaku < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Haku::VERSION
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
