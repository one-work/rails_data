module Datum
  module Model::Err
    extend ActiveSupport::Concern

    included do
      attribute :from_type, :string
      attribute :from_id, :string
      attribute :to_class, :string
      attribute :target, :string

      belongs_to :from, polymorphic: true, optional: true
    end

  end
end
