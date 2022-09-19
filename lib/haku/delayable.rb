# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/string/inflections"

module Haku
  module Delayable
    extend ActiveSupport::Concern

    if defined?(ActiveJob::Base)
      class Job < ActiveJob::Base
        def perform(klass, params)
          klass.call(params)
        end
      end
    end

    class Delayed
      def initialize(service, options={})
        @service = service
        @options = options.reverse_merge(
          job: "::Haku::Delayable::Job",
          queue: Haku.job_queue
        )
      end

      def call(params={})
        if job.present? && defined?(job)
          job.set(@options).perform_later(@service, params)
        else
          @service.call(params)
        end
      end

      private

      def job
        @job ||= begin
          job = @options.delete(:job)
          job.is_a?(String) ? job.safe_constantize : job
        end
      end
    end

    module ClassMethods
      def delayed(options={})
        ::Haku::Delayable::Delayed.new(self, options)
      end
    end
  end
end
