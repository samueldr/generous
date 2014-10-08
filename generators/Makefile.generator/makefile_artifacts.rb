module Artifacts
	class FinalDependency < GeneratorArtifact
		attr_reader :value

		def initialize(value)
			@value = value
		end
	end

end