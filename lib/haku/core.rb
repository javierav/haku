# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require_relative "result"

module Haku
  module Core
    extend ActiveSupport::Concern

    included do
      prepend Callable

      attr_reader :params

      class_attribute :haku_inputs, default: []
      class_attribute :haku_success_callbacks, default: []
      class_attribute :haku_failure_callbacks, default: []
    end

    module ClassMethods
      def inherited(base)
        super

        base.class_eval do
          prepend Callable
        end
      end

      def call(params={})
        new(params).call
      end

      def input(*names)
        self.haku_inputs += names
      end

      def on_success(*methods)
        self.haku_success_callbacks += methods
      end

      def on_failure(*methods)
        self.haku_failure_callbacks += methods
      end
    end

    module Callable
      def call
        result = super

        Result.new(_haku_status, _haku_response.merge(result: result)).tap do
          _haku_run_callbacks
        end
      end
    end

    def initialize(params={})
      @params = params

      self.class.haku_inputs.each do |name|
        define_singleton_method(name) { @params[name] } unless respond_to?(name)
      end
    end

    private

    def success!(response={})
      @_haku_status = :success
      @_haku_response = _haku_normalize_response(response)
      nil
    end

    def failure!(response={})
      @_haku_status = :failure
      @_haku_response = _haku_normalize_response(response)
      nil
    end

    def _haku_normalize_response(response)
      response.is_a?(Hash) ? response : { data: response }
    end

    def _haku_status
      @_haku_status || :success
    end

    def _haku_response
      @_haku_response || {}
    end

    def _haku_run_callbacks
      (self.class.send("haku_#{_haku_status}_callbacks") || []).each { |cb| send(cb) }
    end
  end
end
