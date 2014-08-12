#TODO: More powerful artifacts?

module Artifacts

	class Artifact

	end

	class GeneratorArtifact < Artifact

	end

	class ScriptArtifact < Artifact
		attr_reader :script
		def initialize(script)
			@script = script
		end
	end


	class FileBasedArtifact < Artifact
		attr_reader :fileName

		def initialize(name)
			@fileName = name
			#@originalFileName = originalFileName
		end
	end

	class NativeCompilableArtifact < FileBasedArtifact
		def objectFileName
			temp  = @fileName
			temp = temp.split '/'
			temp = temp.last.split '.'
			temp[1] = 'o'
			temp.join '.'
		end
	end

	class C < NativeCompilableArtifact

	end

	class Cpp < NativeCompilableArtifact

	end
	class Header < FileBasedArtifact

	end



	class CompilerConfigurationArtifact < Artifact
		attr_reader :value

		def initialize(value)
			@value = value
		end
	end

	class Define < CompilerConfigurationArtifact
		attr_reader :key
		def initialize(value)
		if value.is_a? Array
			@key = value[0]
			@value = value[1]
		else
			@key = value
			@value = nil

		end
		end

		def defineString
			defineString = ""
			defineString += "-D#{@key}"
			defineString += "=#{@value}" if @value
			defineString
		end
	end
	class FileBasedCompilerConfigurationArtifact < CompilerConfigurationArtifact
		attr_reader :fileName
		def initialize(name)
			super(name)
			@fileName = name
			#@originalFileName = originalFileName
		end
	end

  class IncludesPath < FileBasedCompilerConfigurationArtifact
  def includeString
		includeSring = ""
		includeSring += "-I#{@value}"
		includeSring
	end
	end



	class LibrariesPath < FileBasedCompilerConfigurationArtifact
		def librariesPathString prefix = '.'
			#prefix ||= '.'
			librariesPathString = ""
			librariesPathString += "-L#{prefix}/#{@value}"
			librariesPathString
		end
	end

	class CFLAGS < CompilerConfigurationArtifact

	end

	class CXXFLAGS < CompilerConfigurationArtifact

	end

	class LDFLAGS < CompilerConfigurationArtifact

	end

	class Framework < CompilerConfigurationArtifact
		def frameworkString
			frameworkString = ""
			frameworkString += "-framework #{@value}"
			frameworkString
		end

		def fileName
			"#{@value}.framework"
		end
	end

  class Library < CompilerConfigurationArtifact
		def libraryString
			libraryString = ""
			libraryString += "-l#{@value}"
			libraryString
		end

		def fileName
			"lib#{@value}.a"
		end
  end
end
