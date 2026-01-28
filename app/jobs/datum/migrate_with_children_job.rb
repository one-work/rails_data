module Datum
  class MigrateWithChildrenJob < ApplicationJob
    queue_as :default

    def perform(record_klass)
      record_class = record_klass.constantize
      record_class.migrate_with_children
    end

  end
end
