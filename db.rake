namespace :db do

	task :connect do
		ActiveRecord::Base.establish_connection(@db_config)
	end
end
