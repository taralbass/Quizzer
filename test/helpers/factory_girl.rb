module FactoryGirl
  def self.registered?(factory)
    FactoryGirl.factory_by_name(factory).present? rescue false
  end
end

module Factory
  # stubbing instantiate/reload allows you to share the same reference
  # in tests and code
  def self.create_with_stubbing(factory, *args)
    object = create factory, *args
    GlobalStub.stubber.stub(object.class).instantiate(GlobalStub.stubber.hash_including('id' => object.id.to_s)) { object }
    GlobalStub.stubber.stub(object).reload { object }
    object
  end

  # stubbing new allows you to share the same reference in tests and code
  def self.build_with_stubbing(factory, *args)
    object = build factory, *args
    GlobalStub.stubber.stub(object.class).new { object }
    object
  end
end
