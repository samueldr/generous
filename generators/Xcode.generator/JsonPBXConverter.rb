require 'json'

#http://emilloer.com/2011/08/15/dealing-with-project-dot-pbxproj-in-ruby/


class String
  alias to_plist to_json
end

class Array
  def to_plist
    items = map { |item| "#{item.to_plist}" }
    "( #{items.join ","} )"
  end
end


class Hash
  def to_plist
    items = map { |key, value| "#{key.to_plist} = #{value.to_plist};" }
    "{ #{items.join} }"
  end
end



class JsonPBXConverter
  def parse_pbxproj filename
    JSON.parse(`plutil -convert json -o - "#{filename}"`)
  end


  def save_pbxproj filename, hash
    File.open(filename, "w") do |file|
      file.write hash.to_plist
    end
  end
end