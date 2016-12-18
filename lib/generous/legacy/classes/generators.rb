module Generators
	GENERATORS_PATH = "/../lib/generous/legacy/generators/"
	#TODO: Move this elsewhere?
	if File.symlink?($0)
		@base_dir = File.dirname(File.readlink($0)) + GENERATORS_PATH
	else
		@base_dir = File.dirname($0) + GENERATORS_PATH
	end

	def self.get_generator generator_name
		#TODO: Read a list of available paths

		generator_package_path = @base_dir + generator_name + ".generator"
		unless Dir.exists? generator_package_path
			puts generator_package_path
			raise "The generator asked for (#{generator_name}) does not exist."
			#TODO : Output all searched for folders.
		end
		require generator_package_path + '/generator'

		unless Generators.const_defined? generator_name
			raise "The #{generator_name} generator class has not been defined in the generator."
		end

		Generators.const_get generator_name
	end

	def self.list_classes
		generators = []
		#TODO: Read from list of available paths.
		#folder will be the block parameter.
		folder = @base_dir
		Dir.entries(folder).each do |d|
			next if d == '.' || d == '..'

			unless File.directory? folder + d
				#TODO: Only on most verbose level of output...
				$stderr.puts "In folder #{folder}, found #{d}, which is not a generator package."
			end

			d = d[0..d.rindex(".")-1]

			generator = self.get_generator d
			if defined? generator.shortDesc
				generators << "#{d} -- #{generator.shortDesc}"
			else
				generators << d
			end
		end

		generators
	end
end
