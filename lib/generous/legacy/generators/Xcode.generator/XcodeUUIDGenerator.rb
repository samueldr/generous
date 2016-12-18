#http://danwright.info/blog/2010/10/xcode-pbxproject-files-3/
#http://stackoverflow.com/questions/8761878/how-to-get-my-mac-address-programmatically-with-ruby
class XcodeUUIDGenerator

  def initialize
    @num = [Time.now.to_i, Process.pid, getMAC]
  end

  def getMAC(interface='en0')
    #addrMAC = `ifconfig #{interface} ether`.split("\n")[1]
    #addrMAC ? addrMAC.strip.split[1].gsub(':','').to_i(16) : 0

    addrMAC = mac_address
    addrMAC ? addrMAC.strip.gsub(':','').to_i(16) : 0

  end


  def mac_address
    platform = RUBY_PLATFORM.downcase
    output = `#{(platform =~ /win32/) ? 'ipconfig /all' : 'ifconfig'}`
    case platform
      when /darwin/
        $1 if output =~ /en1.*?(([A-F0-9]{2}:){5}[A-F0-9]{2})/im
      when /win32/
        $1 if output =~ /Physical Address.*?(([A-F0-9]{2}-){5}[A-F0-9]{2})/im
      # Cases for other platforms...
      else nil
    end
  end

  def generate
    @num[0] += 1
    self
  end

  def to_s
    "%08X%04X%012X" % @num
  end
end