module Datum
  module Ext::Migrate
    extend ActiveSupport::Concern

    def to_model_klass
      raise 'Should Implement in subclass'
    end

    def migrate_with_children
      migrate
      if children.present?
        children.each(&:migrate_with_children)
      end
    end

    def migrate(target = self.class::DEFAULT)
      keys = mapped_attributes(target[:key])
      return if keys.value?(nil)

      to = target[:to].find_or_initialize_by keys
      to.assign_attributes mapped_attributes(target[:map]) if target.key?(:map)
      to.assign_attributes target[:default] if target.key?(:default)
      to.save!
      sync_images(to, target[:img]) if target.key?(:img)
      to
    rescue ActiveRecord::RecordInvalid
      logger.debug "\e[35m  #{to.class}: #{to.errors.details}  \e[0m"
    end

    def mapped_attributes(map = {})
      map.each_with_object({}) do |(key, value), hash|
        if value.respond_to?(:call)
          hash[key] = value.call(self)
        else
          hash[key] = attributes[value]
        end
      end
    end

    def sync_images(to, images)
      images.each do |key, value|
        urls = public_send(value).split(',')
        Com::AttachedUrlSyncJob.perform_later(to, key, *urls)
      end
    end

    class_methods do
      def migrate_later(target_name = 'DEFAULT')
        MigrateJob.perform_later(self.name, target_name)
      end

      def migrate_with_children
      end

      def migrate_with_children_later
        MigrateWithChildrenJob.perform_later(self.name)
      end
    end

  end
end