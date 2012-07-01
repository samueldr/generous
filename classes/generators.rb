module Generators

	class DumbScript
		def self.generate project
			unless project.is_a? Project
				raise "The generator needs a Project, got a #{project.class}."
			end
			$stderr.puts "TODO: Generate..."
		end
	end

end