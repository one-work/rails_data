module Datum
  class MigrateJob < ApplicationJob
    include ActiveJob::Continuable

    def perform(record_klass, target_name)
      record_class = record_klass.constantize
      target = record_class.const_get(target_name)

      step :process, start: record_class.first.id do |step|
        if target[:not].present?
          record_class.where(target[:filter] || {}).where.not(target[:not]).find_each(start: step.cursor) do |i|
            i.migrate(target)
            step.set! i.id
          end
        else
          record_class.where(target[:filter] || {}).find_each(start: step.cursor) do |i|
            i.migrate(target)
            step.set! i.id
          end
        end
      end
    end

  end
end
