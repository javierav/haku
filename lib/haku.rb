# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/string/inflections"
require_relative "haku/controller"
require_relative "haku/core"
require_relative "haku/delayable"
require_relative "haku/eventable"
require_relative "haku/resourceable"
require_relative "haku/version"

module Haku
  mattr_accessor :event_model, default: "Event"
  mattr_accessor :event_property_for_name, default: :name
  mattr_accessor :event_name, default: proc {
    chain = self.class.name.underscore.split("/")
    (chain[0...-1].map(&:singularize) + [chain.last]).join(":")
  }
  mattr_accessor :job_queue, default: :default

  class << self
    def configure
      yield self
    end
  end
end
