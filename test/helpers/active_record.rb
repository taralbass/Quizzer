class ActiveRecord::Base
  def self.nonexistent_id
    last_object = unscoped.last :order => :id
    last_object ? last_object.id + 1 : 1
  end

  def self.latest
    unscoped.last :order => [ :created_at, :id ]
  end

  def add_update_failure_stubbing
    errors.add :base, "stubbed error"
    GlobalStub.stubber.stub(self).save { false }
    GlobalStub.stubber.stub(self).save! { raise ActiveRecord::RecordInvalid, self }
    self
  end
end
