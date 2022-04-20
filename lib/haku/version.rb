# frozen_string_literal: true

module Haku
  module VERSION
    MAJOR = 1
    MINOR = 2
    TINY  = 1
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
  end

  def self.version
    VERSION::STRING
  end

  def self.gem_version
    Gem::Version.new VERSION::STRING
  end
end
