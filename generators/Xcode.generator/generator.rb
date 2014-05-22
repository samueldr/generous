require_relative 'PBXProjGenerator.rb'
require 'FileUtils'
module Generators
  class Xcode

		def self.list_options
			puts "No options available."
		end

		def initialize

		end

		def permute!
		end


		def generate project
			unless project.is_a? Project
				raise "The generator needs a Project, got a #{project.class}."
			end

			defines            = []
			cppFiles           = []
			headerFiles        = []
			includeDirectories = []
			libraries          = []

			# Getting the structure in that form I want
			project.artifacts.each do |art|
				if art.is_a? Artifacts::FileBasedArtifact
					if art.is_a? Artifacts::Cpp
						cppFiles << art
					elsif art.is_a? Artifacts::Header
						headerFiles << art
					end
				elsif art.is_a? Artifacts::CompilerConfigurationArtifact
					if art.is_a? Artifacts::Define
						defines << art
					elsif art.is_a? Artifacts::Library
						libraries << art
					elsif art.is_a? Artifacts::IncludesPath
						includeDirectories << art.value
					end
				end
			end


			projGen = PBXProjGenerator.new
			FileUtils.mkpath "#{project.buildDir}/#{project.name}.xcodeproj"
			projGen.save "#{project.buildDir}/#{project.name}.xcodeproj/project.pbxproj"


		end

	end
end