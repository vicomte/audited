module Audited
  class Sweeper
    @@stored_data = {
      current_remote_address: :remote_ip,
      current_request_uuid: :request_uuid,
      current_user: :current_user
    }

    delegate :store, to: ::Audited

    def around(controller)
      self.controller = controller
      @@stored_data.each { |k,m| store[k] = send(m) }
      yield
    ensure
      self.controller = nil
      @@stored_data.keys.each { |k| store.delete(k) }
    end

    def current_user
      lambda { controller.send(Audited.current_user_method) if controller.respond_to?(Audited.current_user_method, true) }
    end

    def remote_ip
      controller.try(:request).try(:remote_ip)
    end

    def request_uuid
      controller.try(:request).try(:uuid)
    end

    def controller
      store[:current_controller]
    end

    def controller=(value)
      store[:current_controller] = value
    end

    def self.start_sweeper
      ActiveSupport.on_load(:action_controller) do
        if defined?(ActionController::Base)
          ActionController::Base.around_action Audited::Sweeper.new
        end
        if defined?(ActionController::API)
          ActionController::API.around_action Audited::Sweeper.new
        end
      end
    end
  end
end

