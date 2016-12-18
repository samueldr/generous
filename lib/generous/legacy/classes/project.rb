class Project
	attr_reader :name
	attr_reader :artifacts, :artifactsGroup #, :defines, :cppFiles, :headerFiles, :includeDirectories, :library
	attr_accessor :type, :buildDir, :objectDir, :outputPrefix, :outputName, :outputExtension, :options, :pathToProjectRoot, :configurationName, :configurations, :currentConfig, :project_path

	def initialize(name)
		@name = name
		# @defines            = []
		# @cppFiles           = []
		# @headerFiles        = []
		# @includeDirectories = []
		# @library          = []
		# @framework          = []
		# @librariesPath     = []
		# @LDFLags = []
		# @CFLags = []
		# @CXXFLags = []

    resetArtifacts

    @optionList = []
		@options = {}
		@pathToProjectRoot = ""
	end

  def resetArtifacts
    @artifacts = []
    @artifactsGroup = OpenStruct.new
    @artifactsGroup.defines = []
    @artifactsGroup.cppFiles = []
    @artifactsGroup.headerFiles = []
    @artifactsGroup.includeDirectories = []
    @artifactsGroup.library = []
    @artifactsGroup.framework = []
    @artifactsGroup.librariesPath = []
    @artifactsGroup.LDFLags = []
    @artifactsGroup.CFLags = []
    @artifactsGroup.CXXFLags = []
  end

	def includesString
		includeSring = ""
    @artifactsGroup.includeDirectories.each do |include|
			includeSring += "#{include.includeString} "
		end
		includeSring.rstrip
	end

	def frameworksString
		frameworksString = ""
    @artifactsGroup.framework.each do |framework|
			frameworksString += "#{framework.frameworkString} "
		end
		frameworksString.rstrip
	end

	def librariesString
		librariesString = ""
    @artifactsGroup.library.each do |library|
			librariesString += "#{library.libraryString} "
		end
		librariesString.rstrip
	end

	def LDFLAGS_string
		getFlagString @artifactsGroup.LDFLags
	end

	def CFLAGS_string
		getFlagString @artifactsGroup.CFLags
	end

	def CXXFLAGS_string
		getFlagString @artifactsGroup.CXXFLags
	end

	def getFlagString flagList
		flags = ""
		flagList.each do |flag|
			flags += "#{flag.value} "
		end
		flags.rstrip
	end

	def librariesPathsString prefix = ''
		librariesPathsString = ""
    @artifactsGroup.librariesPath.each do |librariesPath|
			librariesPathsString += "#{librariesPath.librariesPathString prefix} "
		end
		librariesPathsString.rstrip
	end

	def definesString
		defineString = ""
    @artifactsGroup.defines.each do |define|
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
          @artifactsGroup.cppFiles << artifact
				elsif artifact.is_a? Artifacts::Header
          @artifactsGroup.headerFiles << artifact
				end
			elsif artifact.is_a? Artifacts::CompilerConfigurationArtifact
				if artifact.is_a? Artifacts::Define
          @artifactsGroup.defines << artifact
				elsif artifact.is_a? Artifacts::Library
          @artifactsGroup.library << artifact
				elsif artifact.is_a? Artifacts::LibrariesPath
          @artifactsGroup.librariesPath << artifact
				elsif artifact.is_a? Artifacts::Framework
          @artifactsGroup.framework << artifact
				elsif artifact.is_a? Artifacts::CFLAGS
          @artifactsGroup.CFLags << artifact
				elsif artifact.is_a? Artifacts::CXXFLAGS
          @artifactsGroup.CXXFLags << artifact
				elsif artifact.is_a? Artifacts::LDFLAGS
          @artifactsGroup.LDFLags << artifact
				elsif artifact.is_a? Artifacts::IncludesPath
          @artifactsGroup.includeDirectories << artifact
				end
			end

		@artifacts ||= []
		@artifacts << artifact
	end

	def setDefaultOptions
    @optionList.each do |option|
				@options[option.option] = option.defaultValue
			end
	end

	def getOptionParser
		OptionParser.new do |opts|
			opts.separator ''
			opts.separator 'Project options'
      @optionList.each do |option|
				if option.booleanOption
					opts.on("--#{option.option}", "#{option.description}") do |generatorName|
						@options[option.option] = generatorName if generatorName
					end
        else
          desc = "#{option.description}"
          desc = "#{desc}  -- Default: #{option.defaultValue}" if option.defaultValue
					opts.on("--#{option.option}", "=#{option.option}", desc) do |generatorName|
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


  def add_option_from_array option
    @optionList << Option.new(option)
  end

  class Option
    attr_reader :option, :defaultValue, :description, :booleanOption

    def initialize(option)
      @option = option[0]
      @description = option[1]
      if option[3]
        @defaultValue = false
        @booleanOption = true
      else
        @defaultValue = option[2]
        @booleanOption = false
      end
    end
  end
end