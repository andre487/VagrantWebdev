module Params
	CURRENT_DIR = File.dirname(__FILE__)
	PROVISION_DIR = CURRENT_DIR + "/provision"

	def Params.windows?
		(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
	end

	def Params.get
		iniValues = {}
		File.open(CURRENT_DIR + "/params.ini", "r") do |paramsFile|
			paramsFile.each_line do |line|
				matches = line.match(/^(.+?)\s*=\s*(.+)$/)
				if matches
					key, val = matches.captures
					iniValues[key] = val
				end
			end
		end

		params = {
			"box" => iniValues["box"],
			"box_url" => iniValues["box_url"],
			"server_ip" => iniValues["server_ip"],
			"memory" => iniValues["memory"],
		}
		if windows?
			params["www_dir"] = iniValues["www_dir.win32"]
		else
			params["www_dir"] = iniValues["www_dir.unix"]
		end

		return params
	end
end
