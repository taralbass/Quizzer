# Normally stubbing is accomplished by including RR::Adapters::TestUnit.
# However, this makes it available only to the test class itself, and
# sometimes it is handy to stub from othe places. Sometimes, furthermore,
# those other places have methods already that conflict with RR
# (such as FactoryGirl, which has its own stub method). Having stubbing
# methods as instance methods is handy, but stubbing is essentially a
# global activity. GlobalStub serves to provide an object against which
# stubbing can be exected from anywhere, without fear of conflict.
module GlobalStub
  @stubbber = Object.new
  @stubber.extend RR::Adapters::TestUnit

  def self.stubber
    @stubber
  end
end
