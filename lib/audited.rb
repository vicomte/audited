require 'active_record'

module Audited
  class << self
    attr_accessor :ignored_attributes, :current_user_method, :max_audits, :auditing_enabled
    attr_writer :audit_class
    attr_writer :sweeper_path

    def audit_class
      @audit_class ||= Audit
    end

    def sweeper_path
      @sweeper_class ||= 'audited/sweeper'
    end

    def store
      Thread.current[:audited_store] ||= {}
    end

    def config
      yield(self)
    end

    def startup
      ::ActiveRecord::Base.send :include, Audited::Auditor
      ::Audited::Sweeper.start_sweeper
    end
  end

  @ignored_attributes = %w(lock_version created_at updated_at created_on updated_on)

  @current_user_method = :current_user
  @auditing_enabled = true
end

require 'audited/auditor'
require 'audited/audit'
require 'audited/sweeper'

