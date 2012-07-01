class Project
	attr_reader :name
	attr_reader :artifacts

	def initialize(name)
		@name = name
	end

	def add_artifact(artifact)
		unless artifact.is_a? Artifacts::Artifact
			raise "You need to give an Artifact to Project.add_artifact"
		end
		@artifacts ||= []
		@artifacts << artifact
	end
end