# frozen_string_literal: true

require "rails/railtie"
require_relative "controller"

module Haku
  class Railtie < ::Rails::Railtie
    initializer "haku.action_controller_base" do
      if Haku.enable_in_action_controller_base
        ActiveSupport.on_load(:action_controller_base) do
          ActionController::Base.include Haku::Controller
        end
      end

      if Haku.enable_in_action_controller_api
        ActiveSupport.on_load(:action_controller_api) do
          ActionController::API.include Haku::Controller
        end
      end
    end
  end
end
