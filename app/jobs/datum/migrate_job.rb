module Datum
  class MigrateJob < ApplicationJob
    queue_as :default

    def perform(record_klass, target_name)
      record_class = record_klass.constantize
      record_class.migrate(record_class.const_get(target_name))
    end

  end
end
