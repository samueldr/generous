module Generators
	class Makefile

		def self.list_options
			puts "No options available."
		end

		def initialize

		end

		def permute!
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

			# Then outputting how I want this in the script.
			outfiles = []


			File.open("Makefile", "w") do |file|
				file.puts "CFLAGS:= #{project.CFLAGS_string}"
				file.puts "CXXFLAGS:=  #{project.CXXFLAGS_string}"
				file.puts "LDFLAGS:=  #{project.LDFLAGS_string}"
				file.puts "DEFINES = #{project.definesString}"
				file.puts "INCLUDES = #{project.includesString}"
				file.puts "LIBRARIES = #{project.librariesString} #{project.frameworksString}"
				file.puts "LIBRARIES_PATHS = #{project.librariesPathsString}"

				space file, 2
				file.puts 'OBJECT_FILES = \\'
			cppFiles.each do |f|
				file.puts "#{f.objectFileName} \\"
			end
				space file, 1



			file.puts 'HEADER_FILES = \\'
			headerFiles.each do |f|
				file.puts "#{f.originalFileName} \\"
			end

				space file

				file.puts '# -----------------------------------------------------'

				space file


				file.puts "all: #{project.buildDir}/#{project.outputFile} $(addprefix #{project.buildDir}/, $(HEADER_FILES))"
				file.puts "	@echo \"-------- Done--------\""
				space file, 2

				file.puts 'clean:'
				file.puts "	rm -rf #{project.buildDir}"

				space file, 2

				file.puts "#{project.buildDir}/#{project.outputFile}: #{project.objectDir} $(addprefix #{project.objectDir}/,$(OBJECT_FILES))"
				case project.type
					when "library-static"
						file.puts "	$(AR) -rcs #{project.buildDir}/#{project.outputFile} $(addprefix #{project.objectDir}/,$(OBJECT_FILES))"
					else
						file.puts "	$(CXX) $(LDFLAGS) -o #{project.buildDir}/#{project.outputFile} $(LIBRARIES_PATHS) $(LIBRARIES) $(addprefix #{project.objectDir}/,$(OBJECT_FILES))"
				end


				file.puts "all: #{project.objectDir} $(addprefix #{project.objectDir}/,$(OBJECT_FILES))"
				space file, 2

				file.puts "#{project.objectDir}:"
				file.puts "	mkdir -p #{project.objectDir}"

				space file, 2


				headerFiles.each do |f|
				file.puts "#{project.buildDir}/#{f.originalFileName}: #{f.fileName}"
				headerDirectory = File.dirname f.originalFileName
					file.puts "	mkdir -p #{project.buildDir}/#{headerDirectory} && cp \"$<\" \"$@\""
					space file, 1

				end

				cppFiles.each do |f|
					file.puts "#{project.objectDir}/#{f.objectFileName}: #{f.fileName}"
					buildCommand = "	$(CXX) \"$<\" $(CXXFLAGS) $(DEFINES) $(INCLUDES)"

				buildCommand += " -c -o \"$@\""
				file.puts "	@echo \"-------- #{f.fileName}--------\""
				file.puts buildCommand
				space file, 2
			end
			end

		end
	end

end