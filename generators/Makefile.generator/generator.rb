require_relative 'makefile_artifacts'

module Generators
	class Makefile

		def self.list_options
			puts "No options available."
		end

		def initialize

		end

		def permute!
		end


    def process_artifact artifactType, artifactValue
      artifactValue = process_erb artifactValue
      return artifactType.new artifactValue
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
			cFiles             = []
			cppFiles           = []
			headerFiles        = []
			includeDirectories = []
			libraries          = []
      finalDependencies = ""
			# Getting the structure in that form I want
			project.artifacts.each do |art|
				if art.is_a? Artifacts::FileBasedArtifact
					if art.is_a? Artifacts::Cpp
						cppFiles << art
					elsif art.is_a? Artifacts::C
							cFiles << art
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
        elsif art.is_a? Artifacts::FinalDependency
          finalDependencies = "#{finalDependencies} #{art.value}"
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
				file.puts "C_SOURCE_FILES = \\"
				cFiles.each do |f|
					file.puts "#{f.fileName} \\"
				end
				space file, 1

				file.puts "CPP_SOURCE_FILES = \\"
				cppFiles.each do |f|
					file.puts "#{f.fileName} \\"
				end

				space file, 2
				file.puts 'CPP_OBJECT_FILES = \\'
			cppFiles.each do |f|
				file.puts "#{f.objectFileName} \\"
			end
				space file, 1

				file.puts 'C_OBJECT_FILES = \\'
				cFiles.each do |f|
					file.puts "#{f.objectFileName} \\"
				end
				space file, 1


			file.puts 'HEADER_FILES = \\'
			headerFiles.each do |f|
				file.puts "#{f.fileName} \\"
			end

				space file

				file.puts '# -----------------------------------------------------'

				space file


				file.puts "all: #{project.buildDir}/#{project.outputFile} $(addprefix #{project.buildDir}/, $(HEADER_FILES))"
				file.puts "	@echo \"-------- Done--------\""
				space file, 2

				file.puts 'clean:'
				file.puts "	rm -rf #{project.buildDir}/#{project.outputFile}"
				file.puts "	rm -rf #{project.objectDir}/*"

=begin
				# C header dependency generation
				space file, 2
				file.puts "# C header dependency generation"
				file.puts <<-EOF
depend: #{project.buildDir}/depend.d

#{project.buildDir}/depend.d: $(CPP_SOURCE_FILES) $(C_SOURCE_FILES)
		@echo "----- Building headers dependency list. ----"
		echo "# Header dependencies " > "#{project.buildDir}/depend.d";
		@echo "Command truncated..."
		@$(foreach F,$^,$(CC) $(CXXFLAGS) $(CFLAGS) $(DEFINES) $(INCLUDES) -MM -MQ "#{project.objectDir}/$(notdir $(F))" "$(F)" >> #{project.buildDir}/depend.d ;)
		sed -i -e 's/\\..*:/.o:/' "#{project.buildDir}/depend.d"
		@echo

cleandeps:
		rm "#{project.buildDir}/depend.d";

-include #{project.buildDir}/depend.d
				EOF
=end

				# Main output artifact
				space file, 2

				file.puts "#{project.buildDir}/#{project.outputFile}: #{finalDependencies} #{project.objectDir} $(addprefix #{project.objectDir}/,$(CPP_OBJECT_FILES)) $(addprefix #{project.objectDir}/,$(C_OBJECT_FILES))"
				case project.type
					when "library-static"
						file.puts "	$(AR) -rcs #{project.buildDir}/#{project.outputFile} $(addprefix #{project.objectDir}/,$(CPP_OBJECT_FILES)) $(addprefix #{project.objectDir}/,$(C_OBJECT_FILES))"
					else
						file.puts "	$(CXX) $(LDFLAGS) -o #{project.buildDir}/#{project.outputFile} $(LIBRARIES_PATHS) $(addprefix #{project.objectDir}/,$(CPP_OBJECT_FILES)) $(LIBRARIES) $(addprefix #{project.objectDir}/,$(C_OBJECT_FILES)) $(LIBRARIES)"
				end


				file.puts "all: #{project.objectDir} $(addprefix #{project.objectDir}/,$(CPP_OBJECT_FILES))"
				space file, 2

				file.puts "#{project.objectDir}:"
				file.puts "	mkdir -p \"#{project.objectDir}\""

				space file, 2


				headerFiles.each do |f|
				file.puts "#{project.buildDir}/#{f.fileName}: #{f.fileName}"
				headerDirectory = File.dirname f.fileName
					file.puts "	mkdir -p \"#{project.buildDir}/#{headerDirectory}\" && cp \"$<\" \"$@\""
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


				cFiles.each do |f|
					file.puts "#{project.objectDir}/#{f.objectFileName}: #{f.fileName}"
					buildCommand = "	$(CC) \"$<\" $(CFLAGS) $(DEFINES) $(INCLUDES)"

					buildCommand += " -c -o \"$@\""
					file.puts "	@echo \"-------- #{f.fileName}--------\""
					file.puts buildCommand
					space file, 2
				end

			end

		end
	end

end
