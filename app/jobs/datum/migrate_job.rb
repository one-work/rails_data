module Datum
  class MigrateJob < ApplicationJob
    queue_as :default

    def perform(record_klass)
      record_class = record_klass.constantize
      record_class.migrate
    end

  end
end
