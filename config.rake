namespace :config do
	task :read do
                config = YAML.load_file("config.yml")

                @config = {}
		@config[:svn_root] = config["svn"]["url"]
		@config["svn_current"] = config["svn"]["url"] + config["svn"]["branch"]["current"]
		@config["svn_production_mirror"] = config["svn"]["url"] + config["svn"]["branch"]["production_mirror"]

                @db_config=config["database"]

		@smtp_config = []
		%w{ host port login password }.each do |param|
			@smtp_config << config["smtp"][param]
		end
		@mail_addresses = []
                %w{ from cc }.each do |param|
                        @mail_addresses << config["smtp"][param]
                end

	end
end

