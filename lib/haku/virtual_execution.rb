module Haku
  class VirtualExecution
    include Core

    input :operation, :params

    def call
      create_klass
      define_call
    end

    private

    def create_klass
      @klass = Class.new

      @klass.include Core
      @klass.include Eventable
      @klass.include Resourceable

      @klass.input :operation, :params
    end

    def define_call
      klass.define_method(:call) do
        case operation.to_sym
        when :create

        end
      end
    end
  end
end
