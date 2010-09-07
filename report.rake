def collect_bugs
	Bug.closed.with_any_keywords("RT").client_ok.patch_candidate.with_assignee
end

def yesterday_revisions(branch)
	messages = {}
	today, yesterday = Time.now.strftime("%Y-%m-%dT00:00:00"), (Time.now - 24*60*60).strftime("%Y-%m-%dT00:00:00")
	output = SVN.log(@config["svn_#{branch}"], :revision => "{#{yesterday}}:{#{today}}")	
	output.grep(/^r[0-9]{4,6}/).each do | line |
		revision_number, author, timestamp = line.split("|")
		if messages[author].nil?
			messages[author] = Array.new
		end
		messages[author].push [revision_number, timestamp]
	end
	messages
end

def check_revisions_in_bugzilla(branch_name)
	yesterday_revisions(branch_name).each do | author, revisions |
		message = []
		revisions.each do | revision, timestamp |
			revision_number = revision[/[0-9]+/]
			# find a bug where revision was committed
			bug_ids = Comment.has_revision(revision_number).find(:all).collect(&:bug_id)
			if bug_ids.empty? 
				bug_ids = ["not committed"]                                                           #[^r\-\s][^0-9\-\s]
				comment = SVN.log(@config["svn_#{branch_name}"], :revision => revision_number).grep(/^[^\-]/)
				comment.shift  # remove first line with rev number
				puts "strange" if comment.empty?
				time = Time.parse(timestamp).strftime("%Y-%m-%d %H:%M")
				message.push [revision, time,  comment.collect(&:chomp).join(" ")].join("  |  ")
			end
		end
		unless message.empty?
			email = Email.new(@smtp_config,@mail_addresses,author,message.join("\n"),branch_name)
			email.send_about_revisions
		end
	end
end

def check_bugs_have_revisions(branch_name)
	not_ready_bugs = Hash.new
	bugs = collect_bugs
	bugs.each do | bug |
		bug_has_commits_in_branch = false
		bug.comments.each do | comment |
			comment.thetext.each_line do | line |
				if line =~ /evision:.[0-9]+/
					revision = line[/[0-9]+/]
					output = SVN.log(@config[:svn_root], :revision => revision, :verbose => "")
					output.each_line do | output_line |
						if output_line =~ /\/#{branch_name}\//
							bug_has_commits_in_branch = true
						end
					end		
				end
			end # comment
		end # all comments
		# add bug's id and description to personal author's list
		assignee = bug.assignee.login_name.to_s
		not_ready_bugs[assignee] = Array.new if not_ready_bugs[assignee].nil?
		not_ready_bugs[assignee] << [bug.bug_id, bug.short_desc] unless bug_has_commits_in_branch
	end # all bugs
	# send notification 
	not_ready_bugs.each do | author, bug_list |
		email = Email.new(@smtp_config,@mail_addresses,author, bug_list.join("  |  "),branch_name)
		email.send_about_bugs
	end
end

namespace :check do
	desc "Check current brach if revisions weren't  submitted to Bugzilla"
	task :current_branch => ["config:read", "db:connect"] do
		check_revisions_in_bugzilla("current")
	end

	desc "Check pro brach if revisions weren't  submitted to Bugzilla"
	task :production_mirror_branch => ["config:read","db:connect"] do
		check_revisions_in_bugzilla("production_mirror")
	end
	
	desc "Check PM bugs that all they have a svn revisions to p_m branch"
	task :bugs_with_pm_commits => ["config:read","db:connect"] do
		check_bugs_have_revisions("production_mirror")
	end

	desc "all three reports"
	task :three_reports => ["config:read","db:connect"] do
		check_revisions_in_bugzilla("current")
		check_revisions_in_bugzilla("production_mirror")
		check_bugs_have_revisions("production_mirror")
	end
end
