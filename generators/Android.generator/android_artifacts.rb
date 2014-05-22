module Artifacts
	class ApplicationMK < GeneratorArtifact
		attr_reader :value

		def initialize(value)
			@value = value
		end
	end

class Android_libraries < GeneratorArtifact
	attr_reader :value
	def initialize(value)
		@value = value
	end
end

	class AndroidMK < GeneratorArtifact
		attr_reader :value

		def initialize(value)
			@value = value
		end
	end

end