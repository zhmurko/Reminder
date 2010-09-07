class Bug < ActiveRecord::Base
	set_primary_key "bug_id"
	set_table_name "bugs"
	has_many :comments, :foreign_key => :bug_id, :primary_key => :bug_id
	has_many :activities, :class_name => "Bug::Activity", :foreign_key => :bug_id, :primary_key => :bug_id
	has_many :keywords_activities, :class_name => "Bug::Activity", :foreign_key => :bug_id, :primary_key => :bug_id, :include => :fielddef, :conditions => ["fielddefs.name = ?","keywords"]
	belongs_to :assignee, :class_name => "User", :foreign_key => :user_id, :foreign_key => :assigned_to
	named_scope :only_ids, {:select => :bug_id }

	named_scope :for_bugs, lambda { | bug_ids|
        	 { :conditions => [ "bug_id in (?)", bug_ids ] }
	        }

	named_scope :without_keywords, lambda { | *args |
	        { :conditions => [ [["NOT FIND_IN_SET(?,REPLACE(bugs.keywords,' ',''))"] * args.size].join(" AND "), *args] } unless args.nil?
	        }
	named_scope :ready_for_build, { :conditions => "bugs.delta_ts >= '2008-01-01 00:00:00' AND bug_status IN ('RESOLVED','CLOSED') AND resolution in ('REMIND')" }
	named_scope :without_the_oldest, { :conditions => "bugs.delta_ts >= '2008-01-01 00:00:00'" }
	named_scope :build_date, lambda { | build_date | { :conditions => ["bugs.tbd = ?", build_date] } }
	
	named_scope :with_any_keywords, lambda { | *args |
                { :conditions => [ [["FIND_IN_SET(?,REPLACE(bugs.keywords,' ',''))"] * args.size].join(" OR "), *args] } unless args.nil?
                }

	named_scope :with_assignee, { :include => :assignee }
	named_scope :closed, {:conditions => "bugs.delta_ts >= '2008-01-01 00:00:00' AND bug_status = 'CLOSED'"}
	named_scope :client_ok, {:conditions => "(bugs.client_desc = 'All' and bugs.cotp in ('NA')) or (bugs.client_desc <> 'All' and bugs.cotp in ('Y'))"}
	named_scope :patch_candidate,	 { :conditions => "bugs.can_patch = 1" }
end
