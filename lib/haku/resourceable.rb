# frozen_string_literal: true

module Haku
  module Resourceable
    def create_resource(parent, attributes, ivar=nil, singleton: nil)
      parent.send(singleton ? "create_#{singleton}" : "create", attributes).tap do |resource|
        instance_variable_set("@#{ivar}", resource) if ivar.present?

        if resource.persisted?
          yield resource if block_given?
          success! resource: resource
        else
          failure! resource: resource, errors: resource.errors
        end
      end
    end

    def update_resource(resource, attributes)
      resource.tap do
        if resource.update(attributes)
          yield resource if block_given?
          success! resource: resource
        else
          failure! resource: resource, errors: resource.errors
        end
      end
    end

    def destroy_resource(resource)
      resource.tap do
        if resource.destroy
          yield resource if block_given?
          success! resource: resource
        else
          failure! resource: resource, errors: resource.errors
        end
      end
    end
  end
end
