# frozen_string_literal: true

require "test_helper"
require "active_job"

ActiveJob::Base.logger = nil

class TestDelayable < Minitest::Test
  include ActiveJob::TestHelper

  class Job < ActiveJob::Base
    def perform(klass, params)
      klass.call(params)
    end
  end

  class Example
    include Haku::Core
    include Haku::Delayable

    input :name

    def call
      "Name #{name}"
    end
  end

  def test_job_enqueue
    Example.delayed(job: TestDelayable::Job).call(name: "Alba")

    assert_enqueued_with(
      job: TestDelayable::Job, args: [TestDelayable::Example, { name: "Alba" }]
    )
  end

  def test_other_global_queue
    Haku.job_queue = :low
    Example.delayed(job: TestDelayable::Job).call(name: "Laura")

    assert_enqueued_with(
      job: TestDelayable::Job, args: [TestDelayable::Example, { name: "Laura" }], queue: "low"
    )

    Haku.job_queue = :default
  end

  def test_other_queue
    Example.delayed(job: TestDelayable::Job, queue: :medium).call(name: "Javier")

    assert_enqueued_with(
      job: TestDelayable::Job, args: [TestDelayable::Example, { name: "Javier" }], queue: "medium"
    )
  end
end
