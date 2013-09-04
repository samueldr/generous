class PBXProjObjectGenerator
  def initialize

  end

  def genConfigurationList configIsVisible, defaultConfigurationName, buildConfigurations
    raise "configIsVisible must be a boolean" unless !!configIsVisible == configIsVisible
    raise "defaultConfigurationName must be a String" unless defaultConfigurationName.kind_of? String
    raise "buildConfigurations must be an array" unless buildConfigurations.kind_of? Array

    {
        "isa" => "XCConfigurationList",
        "defaultConfigurationIsVisible" => configIsVisible ? "1" : "0",
        "defaultConfigurationName" => defaultConfigurationName,
        "buildConfigurations" => buildConfigurations
    }
  end

  def genConfigObject name, buildSetting
    raise "name must be a String" unless name.kind_of? String
    raise "buildSetting must be a Hash or nil" unless buildSetting.kind_of? Hash or buildSetting.nil?
    {
        "isa" => "XCBuildConfiguration",
        "buildSettings" => buildSetting.nil? ? {} : buildSetting,
        "name" => name
    }
  end

  def genGroupObject name, children, sourceTree
    raise "name must be a String" unless name.kind_of? String
    raise "sourceTree must be a String" unless sourceTree.kind_of? String
    raise "children must be an array" unless children.kind_of? Array
    {
        "isa" => "PBXGroup",
        "children" => children,
        "name" => name,
        "sourceTree" => sourceTree

    }
  end

  def genTargetObject name, buildConfigListUUID, productReferenceUUID, productType, buildPhases, dependencies = [], buildRules = []
    #productTypeString = "com.apple.product-type.tool", # #com.apple.product-type.application
    case productType
      when "application"
        productTypeString = "com.apple.product-type.application"
      when "application-cli"
        productTypeString = "com.apple.product-type.tool"
      when "library-static"
        productTypeString =  "com.apple.product-type.library.static"
      when "library-dynamic"
        productTypeString =  "com.apple.product-type.library.dynamic"
      when "framework"
        productTypeString= "com.apple.product-type.framework"
      else
        raise "productType must be either application, application-cli, library-static or library-dynamic"
    end

    {
    "isa" => "PBXNativeTarget",
    "name" => name,
    "buildConfigurationList" => buildConfigListUUID,
    "productReference" => productReferenceUUID,
    "productType" => productTypeString,
    "buildPhases" => buildPhases,
    "dependencies" => dependencies,
    "buildRules" => buildRules
    }
  end


  def genOutputFile productType, name

  #explicitFileType (type : xcode value) --- (bundle : wrapper.application) ( dynamic lib : compiled.mach-o.dylib ) (framework : wrapper.framework) (libstatic : archive.ar) (tool : compiled.mach-o.executable)
    case productType
      when "application"
        productTypeString = "wrapper.application"
        path =  "#{name}.app"
      when "application-cli"
        productTypeString = "compiled.mach-o.executable"
        path =  "#{name}"
      when "library-static"
        productTypeString =  "archive.ar"
        path =  "lib#{name}.a"
      when "library-dynamic"
        productTypeString =  "compiled.mach-o.dylib"
        path =  "#{name}.dylib"
      when "framework"
        productTypeString= "wrapper.framework"
        path =  "#{name}.framework"
      else
        raise "productType must be either application, application-cli, library-static or library-dynamic"
    end


            {
              "isa" => "PBXFileReference",
              "path" => path,
              "includeInIndex" => "0",
              "explicitFileType" => productTypeString,
              "sourceTree" => "BUILT_PRODUCTS_DIR"
            }
  end


  def genInputFileObject name
  {
     "path" => name,
     "isa"  => "PBXFileReference",
     "lastKnownFileType" => "sourcecode.cpp.cpp",
     "sourceTree" => "<group>"
  }
  end

  def genBuildFileObject fileUUID
    {
        "fileRef" => fileUUID,
        "isa" => "PBXBuildFile"
    }
  end

  def genSourceBuildPhase files
   {
    "isa" => "PBXSourcesBuildPhase",
    "buildActionMask" => "2147483647",
    "files" => files,
    "runOnlyForDeploymentPostprocessing" => "0"
   }
  end


end