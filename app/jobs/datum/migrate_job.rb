module Datum
  class MigrateJob < ApplicationJob
    queue_as :default

    def perform(record_klass, target)
      record_class = record_klass.constantize
      record_class.migrate(target)
    end

  end
end
