# Legacy file format.
require 'yaml'

# Allow adding ERB blocks in the generous script.
require 'erb'

module Generous::ConfigParser
	def merge_config old, new
		if old.is_a? Array then
			old.concat new
		elsif old.is_a? Hash then
			old.merge new do |oldkey, oldConfig, newConfig|
				if oldConfig.is_a? Hash
					newConfig.each do |key, value|
						if oldConfig.has_key? key then
							oldConfig[key].concat value
						else
							oldConfig[key] = value
						end
					end
					oldConfig
				else
					# Allow empty collections.
					oldConfig.concat newConfig if newConfig
					oldConfig
				end
			end
		else
			nil
		end
	end

	def process_erb value
		if value.is_a? String
			ERB.new(value).result(binding)
		elsif value.is_a? Array
			value.map! do |v|
				process_erb v
			end
		else
			value
		end
	end

	def include_config configName, configurations
		config  = configurations[configName]
		# TODO : Add error message when passing a configName not found in configurations
		# if config is nil...
		if config == nil then
			print "Config #{configName} does not seem to exist!\n"
			print "Aborting!\n"
			exit 2
		end
		config = {'include' => configName.split(',')} if config.nil?
		if config.has_key? 'include'
			temp =  {}
			config['include'].each do |includedName|

				if  includedName.is_a? Array
					next if not eval(includedName[1])
					includedName = includedName[0]
				end
				included = configurations[includedName]

				if included.nil? then
					puts "Invalid configuration name: #{includedName}"
					exit 1
				end

				included = include_config includedName, configurations	 if included.has_key? 'include'
				if not $config_included.include? includedName then
					$config_included << includedName

					temp = config.merge included do |k, old, new|
						case k
							#When merging, we will always keep the original name.
						when 'name'
							old
						when 'options', 'artifacts', 'preGenerousScripts', 'postGenerousScripts'
							merge_config old, new
						when 'include', 'export'

						else
							old = $options.generator.merge_config k, old, new
							if not old then
								$stderr.puts "I don't know how to merge these properties...'"
								$stderr.puts 'TODO: Make this a warning and find a middle ground for merging...'
								$stderr.puts
								$stderr.puts '====>' + k
								$stderr.puts '==old'
								$stderr.puts old
								$stderr.puts '==new'
								$stderr.puts new
							end
						end
					end

					config = temp
				end
				temp.delete 'include'
			end

			#config = temp
		end
		config
	end

	def process_artifacts project, config
		project.resetArtifacts
		if config['artifacts']
			config['artifacts'].each do |artifactName, artifactValues|
				add_artifact artifactName, artifactValues, project if not artifactValues.nil?
			end
		end
	end

	def add_artifact artifactName, artifactValues, project
		unless Artifacts.const_defined? artifactName
			raise "Unknown artifact type: #{artifactName}"
		end

		artifactType = Artifacts.const_get artifactName

		artifactValues.each do |artifactValue|
			#TODO: De-hardcode the globbing here... Have some kind of magic for containing the initialization of artifacts through the glob...
			#TODO: Decouple the initialization of an Artifact from the parsing of the config? (Have the glob be applied while parsing the config instead?)
			#TODO: Add a Artifacts::PathBase instead of checking for FileBasedArtifact and other path type artifact
			if artifactType < Artifacts::FileBasedArtifact || artifactType < Artifacts::FileBasedCompilerConfigurationArtifact
				# When using a simple string, create the right array.
				if artifactValue.is_a? String or not artifactValue[1] then
					artifactValue = [artifactValue, []]
				end
				artifactValue[0] = ERB.new(artifactValue[0]).result(binding)
				if artifactValue[1].is_a? Array then
					artifactValue[0] = "#{$pathToProjectRoot}#{artifactValue[0]}"
					Dir.globmask(artifactValue[0], artifactValue[1]).each do |file|
						#originalPath = file.clone
						#originalPath.slice! "#{$pathToProjectRoot}"
						project.add_artifact artifactType.new(file)
					end
				elsif artifactValue[1] then
					project.add_artifact artifactType.new(artifactValue[0])
				end
			elsif artifactType < Artifacts::GeneratorArtifact
				artifact = $options.generator.process_artifact artifactType, artifactValue
				project.add_artifact artifact
			else
				artifactValue = process_erb artifactValue
				project.add_artifact artifactType.new(artifactValue)
			end
		end
	end

	module_function :process_erb
	module_function :merge_config
	module_function :include_config
	module_function :process_artifacts
	module_function :add_artifact
end
