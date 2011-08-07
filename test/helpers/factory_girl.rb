module FactoryGirl
  def self.registered?(factory)
    FactoryGirl.factory_by_name(factory).present? rescue false
  end
end
