# frozen_string_literal: true

require "active_support/string_inquirer"

module Haku
  class Result
    def initialize(status, response)
      @status = ActiveSupport::StringInquirer.new(status.to_s)
      @response = response

      @response.each_key do |key|
        define_singleton_method(key) { @response[key] }
      end
    end

    def success?
      @status.success?
    end

    def failure?
      @status.failure?
    end
  end
end
