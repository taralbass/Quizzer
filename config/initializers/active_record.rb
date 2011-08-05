ActiveRecord::Base.default_timezone = :utc

# attributes are protected by default
ActiveRecord::Base.send(:attr_accessible, nil)
