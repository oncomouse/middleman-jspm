require 'middleman-core/cli'

class String
	def colorize(color_code)
		"\e[#{color_code}m#{self}\e[0m"
	end

	def red
		colorize(31)
	end

	def light_blue
		colorize(36)
	end
end

module Middleman
	module Cli
		class JSPM < Thor
			include Thor::Actions
			
			namespace :jspm
			
			desc "jspm [<options>...]", "Use JSPM from within Middleman"
			
			def self.exit_on_failure?
				true
			end
			
			def jspm(*options)
				raise "JSPM".red + " not found, please run:\n\n\t" + "npm install".light_blue + "\n\n" if not File.directory? "node_modules" and not File.directory? "node_modules/jspm"
				begin
					jspm_dir = ::Middleman::Application.server.inst.jspm_dir
				rescue NoMethodError
					raise 'You need to activate the deploy extension in config.rb.'
				end
				
				build_package_json = false
				if not File.exists? "package.json"
					build_package_json = true
					File.open("package.json", "w") do |fp|
						fp.write(JSON.pretty_generate(
							{
								"jspm" => {
									"directories" => {
										"baseURL" => jspm_dir.gsub(/\/jspm_packages$/,"")
									},
									"dependencies" => {},
									"devDependencies" => {
										"babel" => "npm:babel-core@^5.6.4",
										"babel-runtime" => "npm:babel-runtime@^5.6.4",
										"core-js" => "npm:core-js@^0.9.17"
									}
								},
								"dependencies" => {
									"jspm" => ">=0.16.0-beta.3"
								},
								"devDependencies" => {}
							}
						))
					end
				end
				
				system "node node_modules/jspm/jspm.js #{options.join(" ")}"
				
				if build_package_json
					config_js = File.read(jspm_dir.gsub(/\/jspm_packages$/,"")+"/config.js")
					config_js.sub!(/^System.config\(\{/,"System.config({\n  \"baseURL\": \"#{jspm_dir.sub(/\/jspm_packages$/,"").sub(/^source/,"")}\",")
					File.open(jspm_dir.gsub(/\/jspm_packages$/,"")+"/config.js", "w") do |fp|
						fp.write config_js
					end
				end
			end
		end
	end
end