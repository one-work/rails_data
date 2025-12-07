module RailsData
  mattr_accessor :config, default: ActiveSupport::OrderedOptions.new

  config.inflector = :titleize
  config.method_name = :report

end
