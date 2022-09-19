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
      class_attribute :haku_before_call_callbacks, default: []
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

      def before_call(*methods)
        self.haku_before_call_callbacks += methods
      end

      def on_success(*methods)
        self.haku_success_callbacks += methods
      end

      def on_failure(*methods)
        self.haku_failure_callbacks += methods
      end
    end

    Finish = Struct.new("Finish", :status, :payload)

    module Callable
      def call
        response = catch(:finish) do
          (self.class.send(:haku_before_call_callbacks) || []).each { |cb| send(cb) }
          super
        end

        status = response.is_a?(Finish) ? response.status : :success
        payload = response.is_a?(Finish) ? response.payload : response

        Result.new(status, payload).tap do
          haku_run_callbacks(status)
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

    def success!(data=nil)
      throw :finish, Finish.new(:success, data)
    end

    def failure!(data=nil)
      throw :finish, Finish.new(:failure, data)
    end

    def haku_run_callbacks(status)
      (self.class.send("haku_#{status}_callbacks") || []).each { |cb| send(cb) }
    end
  end
end
