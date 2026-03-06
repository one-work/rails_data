module Datum
  module Model::Err
    extend ActiveSupport::Concern

    included do
      attribute :from_class, :string
      attribute :from_id, :string
      attribute :to_class, :string
      attribute :target, :string
    end

  end
end
