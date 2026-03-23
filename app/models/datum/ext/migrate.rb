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

    def migrate(target_name = 'DEFAULT')
      return unless self.class.const_defined?(target_name)
      target = self.class.const_get(target_name)
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
      Err.find_or_create_by(from_type: self.base_class_name, from_id: id, to_class: target[:to].name, target: 'DEFAULT')
      to
    end

    def mapped_attributes(map = {})
      map.each_with_object({}) do |(key, value), hash|
        if value.respond_to?(:call)
          hash[key] = value.call(self)
        else
          hash[key] = attributes[value]
        end
      end.compact
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

      def migrate(target_name = 'DEFAULT')
        return unless const_defined?(target_name)
        target = const_get(target_name)

        find_each do |i|
          i.migrate(target)
        end
      end

      def migrate_with_children
      end

      def migrate_with_children_later
        MigrateWithChildrenJob.perform_later(self.name)
      end
    end

  end
end