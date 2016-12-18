require 'fileutils'
require_relative 'android_artifacts'
require 'nokogiri'
module Generators
	class Android

		def list_options
			puts @optionParser

		end

		def process_artifact artifactType, artifactValue
      artifactValue = process_erb artifactValue
			return artifactType.new artifactValue
		end



		def merge_config key, old, new
			return nil
		end


		def merge_artifacts old, new

		end

		def initialize
			#$pathToProjectRoot = '../..'

			@optionParser = OptionParser.new do |opts|
				opts.separator ''
				opts.separator 'Android generator options'

				opts.on('-s', '--sdk', '=ANDROID_SDK', 'Path to the android sdk') do |android_sdk|
					$options.android_sdk = android_sdk
				end

				opts.on('-t', '--target', '=ANDROID_TARGET', 'Android target ID (see "android list" for a list of possible target)') do |android_target|
					$options.android_target = android_target
				end
			end

			if File.symlink?($0)
				@base_dir = File.dirname(File.readlink($0)) + "/generators/Android.generator/"
			else
				@base_dir = File.dirname($0) + "/generators/Android.generator/"
			end
		end

		def permute!
			@optionParser.permute!
		end

		def space(file, spaceCount =5)
			for i in 1..spaceCount
				file.puts ''
			end
		end

		def generate project
			unless project.is_a? Project
				raise "The generator needs a Project, got a #{project.class}."
			end

			defines            = []
			cFiles           = []
			cppFiles           = []
			headerFiles        = []
			includeDirectories = []
			libraries          = []
			applicationMK = []
			androidMK = []
			android_libraries = []

			# Getting the structure in that form I want
			project.artifacts.each do |art|
				if art.is_a? Artifacts::FileBasedArtifact
					if art.is_a? Artifacts::Cpp
						cppFiles << art
					elsif art.is_a? Artifacts::C
							cFiles << art
					elsif art.is_a? Artifacts::Header
						headerFiles << art
					#elsif art.is_a? Artifacts::LibrariesPath
					end
				elsif art.is_a? Artifacts::CompilerConfigurationArtifact
					if art.is_a? Artifacts::Define
						defines << art
					elsif art.is_a? Artifacts::Library
						libraries << art
					elsif art.is_a? Artifacts::IncludesPath
						includeDirectories << art
					end
				elsif art.is_a? Artifacts::ApplicationMK
					applicationMK << art.value
				elsif art.is_a? Artifacts::AndroidMK
					androidMK << art.value
				elsif art.is_a? Artifacts::Android_libraries
					android_libraries << art.value
				end
			end

			# Then outputting how I want this in the script.
			outfiles = []

			FileUtils.mkdir_p project.buildDir
			Dir.chdir project.buildDir

			if not File.exist? 'res/values/strings.xml'
				FileUtils.mkdir_p 'res/values'
				stringXML = Nokogiri::XML File.open("#{@base_dir}/strings.xml", "rb").read
				stringXML.at_xpath('//resources/string').content = project.name
				File.open('res/values/strings.xml', "w").puts stringXML
			end

			pathToManifest = 'AndroidManifest.xml'
			pathToManifest = "#{@base_dir}/AndroidManifest.xml" if not File.exist? pathToManifest
				androidManifest = Nokogiri::XML File.open(pathToManifest, "rb").read
				if project.currentConfig['nativeActivity'] then

					androidManifest.at_xpath('//manifest')['package'] = "#{project.currentConfig['package_prefix']}.#{project.name}"

					activity = androidManifest.at_xpath('//manifest/application/activity')
					activity['android:name'] = 'android.app.NativeActivity'
					metaData = activity.at_xpath('meta-data')
					metaData = Nokogiri::XML::Node.new 'meta-data', androidManifest if metaData == nil
					metaData['android:name'] = "android.app.lib_name"
					metaData['android:value'] = "#{project.name}"
					activity.add_child metaData
					androidManifest.at_xpath('//manifest/application')['android:hasCode'] = project.currentConfig['hasCode'] if project.currentConfig['hasCode'] != nil

				else
					#FileUtils.cp_r "#{@base_dir}/AndroidManifest.xml", './AndroidManifest.xml'
				end
				File.open('AndroidManifest.xml', "w").puts androidManifest

      FileUtils.rm "project.properties" if File.exist?("project.properties")
      android_libraries_cmd = ''
	  	android_libraries.each do |lib|
        system("#{$options.android_sdk}/tools/android update project --target #{$options.android_target} --path . --name #{project.name} --library #{lib}")
      end
      system("#{$options.android_sdk}/tools/android update project --target #{$options.android_target} --path . --name #{project.name}")
			FileUtils.mkdir_p 'jni'


			File.open("jni/Android.mk", "w") do |file|

				file.puts 'LOCAL_PATH := $(call my-dir)'
				space file, 1

				file.puts 'include $(CLEAR_VARS)'
				space file, 1

				file.puts "LOCAL_MODULE := #{project.name}"
				space file, 1

				file.puts "LOCAL_CFLAGS = #{project.definesString} #{project.CFLAGS_string}"
				space file, 1

				file.puts "LOCAL_CXXFLAGS = #{project.definesString} #{project.CXXFLAGS_string}"
				space file, 1

				file.puts 'LOCAL_C_INCLUDES = \\'
				includeDirectories.each do |f|
					file.puts "$(LOCAL_PATH)/../../../#{f.fileName} \\"
				end
				space file, 1

				file.puts 'LOCAL_SRC_FILES = \\'
				cFiles.each do |f|
					file.puts "../../../#{f.fileName} \\"
				end
				cppFiles.each do |f|
					file.puts "../../../#{f.fileName} \\"
				end
				space file, 1

				file.puts "LOCAL_LDLIBS = #{project.librariesPathsString '../..'} #{project.librariesString}"
				space file, 1


				file.puts "LOCAL_LDFLAGS = #{project.LDFLAGS_string}"
				space file, 1


				androidMK.each do |a|
					line = "#{a[0]} := "
					a[1].each do |value|
						line += "#{value} "
					end
					file.puts line
					space file, 1
				end


				file.puts 'include $(BUILD_SHARED_LIBRARY)'
				space file, 1
			end

			if applicationMK.size > 0 then
				File.open("jni/Application.mk", "w") do |file|
					applicationMK.each do |a|
							line = "#{a[0]} := "
								a[1].each do |value|
									line += "#{value} "
								end
							file.puts line
							space file, 1
					end
				end

			end
		end

	end

end
