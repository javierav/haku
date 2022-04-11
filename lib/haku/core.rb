# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require_relative "result"

module Haku
  module Core
    extend ActiveSupport::Concern

    included do
      attr_reader :params

      class_attribute :haku_success_callbacks, default: []
      class_attribute :haku_failure_callbacks, default: []
    end

    module ClassMethods
      def call(params={})
        new(params).run
      end

      def on_success(*methods)
        self.haku_success_callbacks += methods
      end

      def on_failure(*methods)
        self.haku_failure_callbacks += methods
      end
    end

    def initialize(params={})
      @params = params

      @params.each_key do |key|
        define_singleton_method(key) { @params[key] } unless respond_to?(key)
      end
    end

    def run
      result = call

      Result.new(_haku_status, _haku_response.merge(result: result)).tap do
        _haku_run_callbacks
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
