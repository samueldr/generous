class Project
	attr_reader :name
	attr_reader :artifacts, :defines, :cppFiles, :headerFiles, :includeDirectories, :library
	attr_accessor :type, :buildDir, :objectDir, :outputPrefix, :outputName, :outputExtension, :options, :pathToProjectRoot

	def initialize(name)
		@name = name
		@defines            = []
		@cppFiles           = []
		@headerFiles        = []
		@includeDirectories = []
		@library          = []
		@framework          = []
		@librariesPath     = []
		@optionArtifacts = []
		@LDFLags = []
		@CFLags = []
		@CXXFLags = []

		@options = {}
		@pathToProjectRoot = ""
	end

	def includesString
		includeSring = ""
		@includeDirectories.each do |include|
			includeSring += "#{include.includeString} "
		end
		includeSring.rstrip
	end

	def frameworksString
		frameworksString = ""
		@framework.each do |framework|
			frameworksString += "#{framework.frameworkString} "
		end
		frameworksString.rstrip
	end

	def librariesString
		librariesString = ""
		@library.each do |library|
			librariesString += "#{library.libraryString} "
		end
		librariesString.rstrip
	end

	def LDFLAGS_string
		getFlagString @LDFLags
	end

	def CFLAGS_string
		getFlagString @CFLags
	end

	def CXXFLAGS_string
		getFlagString @CXXFLags
	end

	def getFlagString flagList
		flags = ""
		flagList.each do |flag|
			flags += "#{flag.value} "
		end
		flags.rstrip
	end

	def librariesPathsString
		librariesPathsString = ""
		@librariesPath.each do |librariesPath|
			librariesPathsString += "#{librariesPath.librariesPathString} "
		end
		librariesPathsString.rstrip
	end

	def definesString
		defineString = ""
		@defines.each do |define|
			defineString += "#{define.defineString} "
		end
		defineString.rstrip
	end

	def add_artifact(artifact)
		unless artifact.is_a? Artifacts::Artifact
			raise 'You need to give an Artifact to Project.add_artifact'
		end



			if artifact.is_a? Artifacts::FileBasedArtifact
				if artifact.is_a? Artifacts::Cpp
					cppFiles << artifact
				elsif artifact.is_a? Artifacts::Header
					headerFiles << artifact
				end
			elsif artifact.is_a? Artifacts::CompilerConfigurationArtifact
				if artifact.is_a? Artifacts::Define
					defines << artifact
				elsif artifact.is_a? Artifacts::Library
					@library << artifact
				elsif artifact.is_a? Artifacts::LibrariesPath
					@librariesPath << artifact
				elsif artifact.is_a? Artifacts::Framework
					@framework << artifact
				elsif artifact.is_a? Artifacts::CFLAGS
					@CFLags << artifact
				elsif artifact.is_a? Artifacts::CXXFLAGS
					@CXXFLags << artifact
				elsif artifact.is_a? Artifacts::LDFLAGS
					@LDFLags << artifact
				elsif artifact.is_a? Artifacts::IncludesPath
					includeDirectories << artifact
				end
			elsif artifact.is_a? Artifacts::Option
				@optionArtifacts << artifact
			end

		@artifacts ||= []
		@artifacts << artifact
	end

	def setDefaultOptions
			@optionArtifacts.each do |option|
				@options[option.option] = option.defaultValue
			end
	end

	def getOptionParser
		OptionParser.new do |opts|
			opts.separator ''
			opts.separator 'Project options'
			@optionArtifacts.each do |option|
				if option.booleanOption
					opts.on("--#{option.option}", "#{option.description}") do |generatorName|
						@options[option.option] = generatorName if generatorName
					end
				else
					opts.on("--#{option.option}", "=#{option.option}", "#{option.description}") do |generatorName|
						@options[option.option] = generatorName if generatorName
					end
				end
			end
		end
	end

	def list_options
		puts getOptionParser
	end

	def parse!
		setDefaultOptions
		getOptionParser.parse!
	end

	def outputFile
		outputFile = "#{outputPrefix}#{@outputName}"
		outputFile += ".#{@outputExtension}" if @outputExtension and @outputExtension != ''
		outputFile
	end
end