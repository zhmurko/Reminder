class Email 

	def initialize(smtp_config,mail_addresses,to,table_body, branch_name) # rewrite it!
		@host, @port, @user, @password = smtp_config # from config.yaml
		@from, @cc  = mail_addresses                 # from config.yaml
		@to = to
		@table_body = table_body
                @branch_name = branch_name
	end

	def send_about_bugs
		@subject = "Bugzilla #{@branch_name} branch Reminder"
		@template_name = "bugs"
		send
	end

	def send_about_revisions
		@subject = "SVN #{@branch_name} branch Reminder #{(Time.now - 24*60*60).strftime("%Y-%m-%d")}"
		@template_name = "revisions"
		send
	end

private
	def send
		recipient_list = @to.split(",") + @cc.split(",")
		#   mailsever_host = "localhost"
		# concatenate path to template  <template_name>.erb
		template_filename = [File.dirname(__FILE__),@template_name+".erb"].join File::Separator
		# read content
		template_body = File.open(template_filename, 'rb') { |f| f.read }
		# substitute varibables int template
		message = ERB.new(template_body, 0, "%<>")
		# erb to text
		message = message.result(binding)
		# create a SMTP session
		session = Net::SMTP.new(@host,@port) # open
		session.start(@host,@user,@password, :login) do |smtp| # connect with authenticate "LOGIN" type
			smtp.send_message(message, @from, recipient_list) # send
		end # close
	end
end

