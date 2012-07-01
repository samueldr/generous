#TODO: More powerful artifacts?

module Artifacts

	class Artifact

	end

	class FileBasedArtifact < Artifact
		attr_reader :fileName

		def initialize(name)
			@fileName = name
		end
	end

	class Cpp < FileBasedArtifact

	end
	class Header < FileBasedArtifact

	end

	class CompilerConfigurationArtifacts < Artifact
		attr_reader :value

		def initialize(value)
			@value = value
		end
	end

	class Define < CompilerConfigurationArtifacts
	end

end
