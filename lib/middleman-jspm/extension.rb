# Require core library
require 'middleman-core'

module Middleman
	class JSPMExtension < Extension
		option :jspm_dir, "source/javascripts/jspm_packages", "Set the directory where JSPM installs packages."

		def initialize(app, options_hash = {}, &block)
			super
			app.set :jspm_dir, options.jspm_dir
			app.after_build do |builder|
				require 'fileutils'
				require 'uglifier'
	
				modules = jspm_get_modules()
	
				if modules.length > 0
					FileUtils.mkdir_p "#{jspm_dir.gsub('source','build').gsub('/jspm_packages','')}/"
					
					assets = [
						"jspm_packages/system",
						"config"
					]
					
					File.open("#{jspm_dir.gsub('source','build').gsub('/jspm_packages','')}/system.js","w") do |fp|
						fp.write assets.map{|x| sprockets.find_asset(x).to_s }.join("\n")
					end
				end
	
				modules.each do |m|
					command = m["self-executing"] ? "bundle-sfx" : "bundle"
					additions_and_subtractions = ""
					if(m["include"] && m["include"].kind_of?(Array))
						additions_and_subtractions += " - " + m["include"].join(" - ")
					end
					if(m["exclude"] && !m["self-executing"] && m["exclude"].kind_of?(Array))
						additions_and_subtractions += " - " + m["exclude"].join(" - ")
					end
					system("node node_modules/jspm/jspm.js #{command} #{m["name"]}#{additions_and_subtractions} #{jspm_dir.gsub('source','build').gsub('/jspm_packages','')}/#{m["name"]}.js")
				end
	
				if modules.length > 0
					Dir.glob("#{jspm_dir.gsub('source','build').gsub('/jspm_packages','')}/**/*.js").each do |file|
						puts "Uglifying #{file}"
						compressed_source = Uglifier.compile(File.read(file))
						File.open(file, 'w') do |f_pointer|
							f_pointer.write(compressed_source)
						end
					end
				end
			end
		end
		def registered(app, options_hash = {}, &block)
			
		end
		
		def after_configuration
			app.sprockets.append_path options.jspm_dir
		end
		
		helpers do
			def jspm_path(package, source="npm")
				Dir.glob("#{jspm_dir}/#{source}/#{package}*").map{|x| if File.directory? x then x else nil end }.delete_if{|x| x.nil? }.sort do |a,b|
					b.gsub("#{jspm_dir}/#{source}/#{package}@","").split('.').map { |e| e.to_i } <=> a.gsub("#{jspm_dir}/github/twbs/bootstrap-sass@","").split('.').map { |e| e.to_i }
				end.first
			end
	
			def jspm_get_modules()
				if sprockets.find_asset("modules.json")
					JSON.parse(sprockets.find_asset("modules.json").to_s)
				elsif File.exists?('modules.json')
					JSON.parse(File.read("modules.json"))
				else
					[]
				end
			end
	
			def jspm_include_module(name)
				modules = jspm_get_modules()
		
				m = modules.find_index{|m| m["name"] == name }
		
				return if m.nil?
		
				if build?
					if modules[m]["self-executing"]
						"<script src=\"#{asset_path(:js, name)}\"></script>"
					else
						"<script>System.import('#{name}');</script>"
					end
				else
					"<script>System.import('#{name}');</script>"
				end
			end
	
			def jspm_include_environment()
				if build?
					include_system = false
					modules = jspm_get_modules()
			
					modules.each do |mod|
						if !mod["self-executing"]
							include_system = true
							break
						end
					end
					if include_system
						javascript_include_tag("system")
					end
				else
					javascript_include_tag	"jspm_packages/system.js", "config.js" 
				end
			end	
		end
		alias :included :registered
	end
end