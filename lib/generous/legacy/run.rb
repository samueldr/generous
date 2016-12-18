#!/usr/bin/env ruby

# Basic dependencies.
require 'ostruct'
require 'optparse'

# Used to print details on exceptions.
require 'pp'

require 'generous/legacy/generous'
# Include everything in the global scope.
include Generous
# ERB scripts are using them.
include Prettify

# Legacy version number
# NEVER INCREASE 0.X, IT SHOULD ALWAYS BE 0.1.X
VERSION = "0.1.2"

$config_included = []

###############################################################################
# Options and parameters handling                                             #
###############################################################################

# Default values
DEFAULT_PROJECT_FILE = "generous.project"
# Default options
$options = OpenStruct.new(
	:show_banner    => true,
	:project_file   => DEFAULT_PROJECT_FILE,
	:current_config => nil,
	:generator      => nil,
	:list_config_options => false,
	:list_exported_config => false,
	:list_all_config => false,
	:project_path => Dir.pwd,
	:build_dir => nil
)
$pathToProjectRoot = ''


@optionParser = OptionParser.new do |opts|
	opts.banner =  "Usage : #{File.basename $PROGRAM_NAME} [OPTION] [-- [GENRATOR OPTION]] [-- [PROJECT OPTION]]"
	opts.separator 'Generates a project based on the configuration passed.'

	opts.separator ''
	opts.separator 'Global options'

	opts.on('-h', '--help', 'Shows this help.') do
		Prettify.show_banner
		$options.show_banner = false
		puts opts
		if $options.generator.respond_to? 'list_options'
			$options.generator.list_options
		end
		$options.list_config_options = true
	end

	opts.on('--no-banner', 'Do not output the ASCII art banner.') do
		$options.show_banner = false
	end

	opts.separator ""
	opts.separator 'Project generation options'
	opts.on('-p', '--project-file', '=FILENAME', 'Project file to use.', "Default: #{DEFAULT_PROJECT_FILE}") do |file|
		$options.project_file = file
		$pathToProjectRoot = File.dirname file
		$pathToProjectRoot += '/' if $pathToProjectRoot != ''
	end

	opts.on('-b','--build-dir','=DIR', 'Set the build directory.') do |build_dir|
		$options.build_dir = build_dir

	end

	opts.on('-c','--config','=CONFIGS', 'The configuration to use when outputting.',
			'Defaults to the one specified by the defaultConfiguration or the first one.') do |config|
		$options.current_config = config
	end

	opts.on('-C', '--list-config', 'Prints a list of exported configurations.') do
		$options.list_exported_config = true
		$options.show_banner = false

	end



	opts.on('--list-all-config', 'Prints a list of all configurations.') do
		$options.list_all_config = true
		$options.show_banner = false

	end

	opts.separator ''
	opts.separator 'Generator options'
	opts.on('-G', '--list-generators', 'Prints a list of available generators.') do
		puts 'List of available generators:'
		Generators.list_classes.each do |g|
			puts "  #{g}"
		end
		exit 0
	end

	opts.on('--list-config-options', 'Prints the options of the selected configuration.') do
		$options.list_config_options = true
	end

	opts.on('-g','--generator','=GENERATOR', 'The generator to use.', 'Defaults to Makefile.') do |generatorName|
		$options.generator = Generators.get_generator generatorName
		$options.generator = $options.generator.new
	end

	opts.on('--version') do
		puts "Generous legacy script (#{VERSION})"
		exit 0
	end

end

@optionParser.permute!
$options.generator = Generators.get_generator('Makefile').new if $options.generator == nil
$options.generator.permute! if 	$options.generator

Prettify.show_banner


###############################################################################
# Project file parsing                                                        #
###############################################################################

# TODO: Create a class to handle the configuration (parsing, validating...)
# TODO: Check kwalify http://www.kuwata-lab.com/kwalify/
begin
	configFile = YAML::load(File.open($options.project_file))
rescue YAML::SyntaxError => e
	$stderr.puts 'Error while analyzing YAML configuration.'
	$stderr.puts e.message
	$stderr.puts "In file #{$options.project_file}"
	exit 1
	rcue Errno::ENOENT => e
	# When the file does not exist.
	$stderr.puts e.message
	exit 1
end
configFile.each do |projectName, projectConfigFile|

	project = Project.new projectName
	$project = project
	$project.project_path = $options.project_path


	#project.pathToProjectRoot = $pathToProjectRoot
	#Setting the current config
	if $options.current_config
		configName = $options.current_config
	elsif projectConfigFile['defaultConfiguration']
		configName = projectConfigFile['defaultConfiguration']
	else
		configName =  projectConfigFile['configurations'].first[0]
	end
	currentConfig = projectConfigFile['configurations'][configName]
	project.configurationName = configName
	project.configurations = projectConfigFile['configurations']

	puts "Running generous for configName: '#{configName}'"

	currentConfig = ConfigParser.include_config project.configurationName, project.configurations
	project.currentConfig = currentConfig

	#set the project type
	if currentConfig.has_key? 'type'
		project.type = currentConfig['type']
	elsif projectConfigFile.has_key? 'type'
		project.type = projectConfigFile['type']
	else
		project.type = "application-cli"
	end


	#set the project outputName
	if currentConfig.has_key? 'outputName'
		project.outputName = currentConfig['outputName']
		elseif projectConfigFile.has_key? 'outputName'
		project.outputName = projectConfigFile['outputName']
	else
		project.outputName = project.name
	end

	#set the project outputPrefix
	if currentConfig.has_key? 'outputPrefix'
		project.outputPrefix = currentConfig['outputPrefix']
	elsif projectConfigFile.has_key? 'outputPrefix'
		project.outputPrefix = projectConfigFile['outputPrefix']
	else
		case project.type
		when "library-static"
			project.outputPrefix = 'lib'
		else
			project.outputPrefix = ''
		end
	end


	#set the project outputExtension
	if currentConfig.has_key? 'outputExtension'
		project.outputExtension = currentConfig['outputExtension']
	elsif projectConfigFile.has_key? 'outputExtension'
		project.outputExtension = projectConfigFile['outputExtension']
	else
		case project.type
		when 'library-static'
			project.outputExtension = 'a'
		when 'application-cli'
			if OS.windows?
				project.outputExtension = 'exe'
			else
				project.outputExtension = ''
			end
		else
			if OS.windows?
				project.outputExtension = 'exe'
			else
				project.outputExtension = ''
			end
		end
	end


	#set the buildDir
	if $options.build_dir
		project.buildDir = $options.build_dir
	elsif currentConfig.has_key? 'buildDir'
		project.buildDir = currentConfig['buildDir']
	elsif projectConfigFile.has_key? 'buildDir'
		project.buildDir = projectConfigFile['buildDir']
	else
		project.buildDir = "build/#{project.name}/#{configName}"
	end
	#set the objectDir
	if currentConfig.has_key? 'objectDir'
		project.objectDir = currentConfig['objectDir']
	elsif projectConfigFile.has_key? 'objectDir'
		project.objectDir = projectConfigFile['objectDir']
	else
		project.objectDir = "#{project.buildDir}/obj"
	end



	if currentConfig.has_key? 'options'
		currentConfig['options'].each do |option|
			option[2] = ERB.new(option[2]).result(binding) if option[2].is_a? String
			project.add_option_from_array option
		end
	end

	begin
		project.parse!
	rescue OptionParser::InvalidOption => e
		$stderr.puts "Error while parsing command-line input."
		$stderr.puts e.message.capitalize!
		exit 1
	end

	if $options.list_exported_config or $options.list_all_config then

		if $options.list_exported_config then
			puts 'List of exported configurations:'
		else
			puts 'List of all configurations:'
		end
		project.configurations.each do |configName, config|
			puts configName if config['export'] or $options.list_all_config
		end
		exit 0
	end

	if $options.list_config_options
		project.list_options
		exit 0
	end


	ConfigParser.process_artifacts project, currentConfig      #we process the artifacts a first time to get correct compiler strings for the scripts

	if currentConfig.has_key? 'preGenerousScripts'
		puts "Executing preGenerousScripts for #{project.configurationName}..."
		i = 0
		currentConfig['preGenerousScripts'].each do |script|
			i += 1
			puts "Script #{i}/#{currentConfig['preGenerousScripts'].length}"
			begin
				eval(script)
			rescue Exception => e
				print "\n"
				pp e
				exit 1
			end
		end
		print "\n"
	end

	ConfigParser.process_artifacts project, currentConfig

	config = currentConfig



	unless $options.generator
		$stderr.puts 'A generator has not been selected.'
		$stderr.puts 'Please select a generator.'
		exit 1
	end
	puts "Generating a project using #{$options.generator.class} generator."
	$options.generator.generate project

	Dir.chdir $project.project_path

	if currentConfig.has_key? 'postGenerousScripts'
		currentConfig['postGenerousScripts'].each do |script|
			eval(script)
		end
	end

end

Prettify.puts_banner('Done.')
