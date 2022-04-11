# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require_relative "haku/core"
require_relative "haku/railtie" if defined?(Rails)
require_relative "haku/resourceable"
require_relative "haku/version"

module Haku
  mattr_accessor :enable_in_action_controller_base, default: true
  mattr_accessor :enable_in_action_controller_api, default: true
end
