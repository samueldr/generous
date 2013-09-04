
require_relative 'XcodeUUIDGenerator.rb'
require_relative 'JsonPBXConverter.rb'
require_relative 'PBXProjGenerator.rb'

 jsonConverter = JsonPBXConverter.new



# READ

bob = jsonConverter.parse_pbxproj "/Users/dupuisj/Desktop/testRubyProject/testRubyProject.xcodeproj/project.pbxproj"
rootObj = bob['rootObject']
debugVar =  bob["objects"]["51F96D5915A11363005FA6AA"]
debugVar2 =  bob["objects"]["51F96D5815A11363005FA6AA"]

stoptest= 2

#jsonConverter.save_pbxproj "/Users/dupuisj/Desktop/testRubyProjectOverwrite/testRubyProject.xcodeproj/project.pbxproj", bob


projGen = PBXProjGenerator.new

projGen.save "/Users/dupuisj/Desktop/testGenerated/testGenerated.xcodeproj/project.pbxproj"