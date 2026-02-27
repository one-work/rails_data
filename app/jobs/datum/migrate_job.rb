module Datum
  class MigrateJob < ApplicationJob
    include ActiveJob::Continuable

    def perform(record_klass, target_name)
      record_class = record_klass.constantize

      step :process, start: record_class.first.id do |step|
        find_each(start: step.cursor) do |i|
          i.migrate(record_class.const_get(target_name))
          step.set! i.id
        end
      end
    end

  end
end
