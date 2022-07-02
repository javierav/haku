# frozen_string_literal: true

require "active_support/concern"

module Haku
  module Delayable
    extend ActiveSupport::Concern

    class Job < ActiveJob::Base
      queue_as { Haku.job_queue }

      def perform(klass, params)
        klass.call(params)
      end
    end if defined?(ActiveJob::Base)

    module ClassMethods
      def delayed_call(params={})
        if defined?(::Haku::Delayable::Job)
        ::Haku::Delayable::Job.perform_later(self, params)
        else
          call(params)
        end
      end
    end
  end
end
