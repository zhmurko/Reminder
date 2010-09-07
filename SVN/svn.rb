class SVN

 def self.run(params)
    command = "svn"
   `#{command} #{params}`
 end

 def self.help
   SVN.run("help")
 end

 def self.list(url)
 end

 def self.log(url, params = {})
	params_line = SVN.parse(params)
#	puts params_line
	SVN.run ["log",params_line,url].join(" ")
 end

private
	
 def self.parse(options = {})
  output = ["--no-auth-cache --config-dir /root/.subversion/"]
  options.each do | key,value |
	key = key.to_s.gsub("_","-")
  	output.push " --"+key+" "+value.to_s
  end
  output.join(" ")
 end

end
