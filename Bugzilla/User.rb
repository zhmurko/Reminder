class User < ActiveRecord::Base
 set_primary_key "userid"
 set_table_name "profiles"

#dd has_many :bugs,:class_name => "Bug", :foreign_key => :bug_id, :primary_key => :bug_id
end
