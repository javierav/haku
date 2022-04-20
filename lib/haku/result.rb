# frozen_string_literal: true

require "active_support/string_inquirer"

module Haku
  class Result
    def initialize(status, payload)
      @status = ActiveSupport::StringInquirer.new(status.to_s)
      @payload = payload

      return unless @payload.respond_to?(:to_h)

      @payload.to_h.each_key do |key|
        define_singleton_method(key) { @payload[key] }
      end
    end

    def result
      @payload
    end

    def success?
      @status.success?
    end

    def failure?
      @status.failure?
    end
  end
end
