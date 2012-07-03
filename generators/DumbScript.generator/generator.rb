module Generators
	class DumbScript

		def self.generate project
			unless project.is_a? Project
				raise "The generator needs a Project, got a #{project.class}."
			end

			defines            = []
			cppFiles           = []
			headerFiles        = []
			includeDirectories = []
			libraries          = []

			# Getting the structure in that form I want
			project.artifacts.each do |art|
				if art.is_a? Artifacts::FileBasedArtifact
					if art.is_a? Artifacts::Cpp
						cppFiles << art.fileName
					elsif art.is_a? Artifacts::Header
						headerFiles << art.fileName
					end
				elsif art.is_a? Artifacts::CompilerConfigurationArtifacts
					if art.is_a? Artifacts::Define
						defines << art.value
					elsif art.is_a? Artifacts::Libraries
						libraries << art.value
					elsif art.is_a? Artifacts::IncludePaths
						includeDirectories << art.value
					end
				else
					puts art.class.name + " : UNHANDLED"
				end
			end

			# Then outputting how I want this in the script.
			outfiles = []

			script_name = "#{project.name}_build_script.sh"

			File.open(script_name, "w") do |file|
				file.puts "#!/bin/bash -ue"
				file.puts "mkdir -p build"
				params = ""
				defines.each do |d|
					params << %/ -D"#{d}" /
				end
				includeDirectories.each do |i|
					params << %/ -I"#{i}" /
				end

				i = 0

				cppFiles.each do |f|
					i       = i.next
					outfile = "build/objs/#{f}.o"
					outdir  = outfile.split "/"
					outdir.pop
					outdir = outdir.join "/"
					file.puts "echo [#{i}/#{cppFiles.count}] #{f}"
					file.puts %Q{mkdir -p #{outdir}}
					file.puts %Q{c++ #{params} -o "#{outfile}" -c "#{f}" }
					outfiles << outfile
				end

				libFileName = "lib" + project.name + ".a"

				#TODO: Check what kind of target it outfile.puts...
				file.puts "echo Linking..."
				file.puts "ar cr build/libtemp.a #{outfiles.join(" ")}"
			end

		end
	end

end