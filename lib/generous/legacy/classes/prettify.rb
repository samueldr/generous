module Generous::Prettify
	# Small utility function to output the lovely banner.
	def show_banner
		return unless $options.show_banner
		puts <<BANNER
    ____   ____   ____   ___________  ____  __ __  ______
   / ___\\_/ __ \\ /    \\_/ __ \\_  __ \\/  _ \\|  |  \\/  ___/
  / /_/  >  ___/|   |  \\  ___/|  | \\(  <_> )  |  /\\___ \\
  \\___  / \\___  >___|  /\\___  >__|   \\____/|____//____  >
 \\_____/      \\/     \\/     \\/   +-> project generator\\/
                                 +------> (Legacy version)
BANNER
	end

	def puts_banner text, col = 40, char = '*'
		puts ''.rjust(col, char)
		puts "*#{text.center( col - 2 )}*"
		puts ''.rjust(col, char)
	end

	module_function :show_banner
	module_function :puts_banner
end
