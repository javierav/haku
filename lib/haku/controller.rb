# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/hash/reverse_merge"

module Haku
  module Controller
    extend ActiveSupport::Concern

    included do
      attr_reader :execution
    end

    def execute(action, params={})
      @execution = action.call(params.reverse_merge(default_execute_params || {}))
    end

    def default_execute_params
      { current_user: current_user } if respond_to?(:current_user)
    end

    def virtual_execute(operation, params={})
      @execution = VirtualExecution.call(
        operation: operation, params: params.reverse_merge(default_execute_params || {})
      )
    end
  end
end
