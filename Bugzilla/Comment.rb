class Comment < ActiveRecord::Base
 set_primary_key "bug_id"
 set_table_name "longdescs"

 default_scope :order => 'bug_when ASC'

 belongs_to :bug,:class_name => "Bug", :foreign_key => :bug_id, :primary_key => :bug_id

 named_scope :in_period, lambda { | start_time, end_time |
	{ :conditions => [ "bug_when >= ? and bug_when <= ?", start_time, end_time ]}
	 }

 named_scope :for_bugs, lambda { | bug_ids| 
	 { :conditions => [ "bug_id in (?)", bug_ids ] }
	}

 named_scope :has_revision, lambda { | revision | 
	{ :conditions =>  "thetext like '%evision: #{revision}%'" }
	}

 named_scope :only_ids, {:select => :bug_id }


# named_scope :exclude_keywords, lambda { | *args |
#	 { :joins => :bug, :conditions => [ [["NOT FIND_IN_SET(?,REPLACE(bugs.keywords,' ',''))"] * args.size].join(" AND "), *args] } unless args.nil?
#	}
# named_scope :ready_for_build, { :joins => :bug, :conditions => "bugs.bug_status IN ('RESOLVED','CLOSED') AND bugs.resolution in ('REMIND')" }
# named_scope :previous_build, lambda { | build_date | { :joins => :bug, :conditions => ["bugs.tbd = ?", build_date] } }
end	
