# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"

module Haku
  module Eventable
    extend ActiveSupport::Concern

    included do
      class_attribute :haku_success_events, default: []
      class_attribute :haku_failure_events, default: []

      on_success :haku_process_events_for_success
      on_failure :haku_process_events_for_failure
    end

    module ClassMethods
      def event(options={})
        on = options.delete(:on)&.to_sym || :success

        send("haku_#{on}_events=", send("haku_#{on}_events") + [options])
      end
    end

    def haku_process_events_for_success
      haku_process_events(:success)
    end

    def haku_process_events_for_failure
      haku_process_events(:failure)
    end

    def haku_process_events(on)
      send("haku_#{on}_events").each do |evt|
        haku_create_event(haku_prepare_event_data(evt))
      end
    end

    def haku_prepare_event_data(evt, data={})
      data.tap do
        haku_event_data_base(data)
        haku_event_data_name(data, evt)
        haku_event_data_values(data, evt)
      end
    end

    def haku_event_data_base(data)
      Haku.event_properties.each do |property|
        haku_event_data_base_value_for_property(data, property)
      end
    end

    def haku_event_data_base_value_for_property(data, property)
      if instance_variable_defined?("@event_#{property}")
        data[property] = instance_variable_get("@event_#{property}")
      elsif respond_to?("event_#{property}", true)
        data[property] = send("event_#{property}")
      elsif instance_variable_defined?("@#{property}")
        data[property] = instance_variable_get("@#{property}")
      elsif respond_to?(property, true)
        data[property] = send(property)
      end
    end

    def haku_event_data_name(data, evt)
      key = Haku.event_property_for_name.to_sym
      data[key] = haku_process_value(evt[key] || Haku.event_name)
    end

    def haku_event_data_values(data, evt)
      evt.except(Haku.event_property_for_name.to_sym).each_pair do |key, value|
        data[key] = haku_process_value(value)
      end
    end

    def haku_process_value(value)
      if value.respond_to?(:call)
        instance_exec(&value)
      else
        value.is_a?(Symbol) ? haku_process_symbol_value(value) : value
      end
    end

    def haku_process_symbol_value(value)
      instance_variable_defined?("@#{value}") ? instance_variable_get("@#{value}") : send(value)
    end

    def haku_create_event(data)
      Haku.event_model.safe_constantize&.create(data)
    end
  end
end
