class Bug::Activity < ActiveRecord::Base
	set_primary_key "bug_id"
	set_table_name "bugs_activity"

	belongs_to :bug, :class_name => "Bug", :foreign_key => :bug_id, :primary_key => :bug_id
	has_many :fielddef, :foreign_key => :fieldid, :primary_key => :fieldid

	named_scope :when_became, lambda { | keyword |  {:order => "bug_when DESC", :conditions => ["FIND_IN_SET(?,REPLACE(added,' ',''))", keyword] } }


end