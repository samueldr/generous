require_relative "JsonPBXConverter.rb"
require_relative "PBXProjObjectGenerator.rb"

class PBXProjGenerator
  def initialize
    @uuidGenerator = XcodeUUIDGenerator.new
    @jsonConverter = JsonPBXConverter.new
    @objectGenerator = PBXProjObjectGenerator.new

    @TODO_REF = "0"
    @hardCoded = {}
    @projVariable ={}

    @uuidRef = {}
    @newProjHash = {}

    @newProjHash ={}

    initHardCoded
    initProjVariable


    initUUIDRef
    initProjHash
    initRootObject
    initMainGroupObject
    initGlobalConfigurationListObject
    initProductGroupObject
    initTargets
  end


  def initHardCoded
    @hardCoded[:compatibilityVersion] = "Xcode 3.2"
    @hardCoded[:hasScannedForEncodings] = 0.to_s
    @hardCoded[:objectVersion] = 46.to_s
    @hardCoded[:archiveVersion] = 1.to_s
    @hardCoded[:LastUpgradeCheck] = 0430.to_s
    @hardCoded[:developmentRegion] = "English"
    @hardCoded[:projectDirPath] = ""
    @hardCoded[:projectRoot] = ""
    @hardCoded[:knownRegions] = ["en"]
    @hardCoded[:defaultConfigurationIsVisible] = false
  end


  def initProjVariable
    @projVariable[:ORGANIZATIONNAME] = "Anhero Inc."

    ######################

    @projVariable[:configNames] = ["Debug"]


    initGlobalConfigVar
    initTargetsVar
  end




  def initUUIDRef
    @uuidRef[:rootObject] = @uuidGenerator.generate.to_s
    @uuidRef[:productRefGroup] = @uuidGenerator.generate.to_s
    @uuidRef[:mainGroup] = @uuidGenerator.generate.to_s
    @uuidRef[:buildConfigurationList] = @uuidGenerator.generate.to_s





    initGlobalConfigUUID
    initTargetsUUID
  end

  def initGlobalConfigUUID
    @uuidRef[:globalConfigObject] = {}
    @projVariable[:configNames].each do |name|
      @uuidRef[:globalConfigObject][name] = @uuidGenerator.generate.to_s
    end
  end

  def initTargetsUUID
    @uuidRef[:targets] = {}
    @projVariable[:targetsName].each do |targetName|
      @uuidRef[:targets][targetName] = {}
      @uuidRef[:targets][targetName][:UUID] = @uuidGenerator.generate.to_s
      @uuidRef[:targets][targetName][:configList] = @uuidGenerator.generate.to_s

      @uuidRef[:targets][targetName][:product] = @uuidGenerator.generate.to_s

      @uuidRef[:targets][targetName]["configs"] = {}
      @projVariable[:configNames].each do |configName|
        @uuidRef[:targets][targetName]["configs"][configName] = @uuidGenerator.generate.to_s
      end

    end
  end




  def getGlobalConfigUUIDArray
    @uuidRef[:globalConfigObject].values
  end

  def getGlobalConfigUUID configName
    @uuidRef[:globalConfigObject][configName]
  end

  def getRootUUID index
    @uuidRef[index]
  end

  def getTargetUUID targetName
    @uuidRef[:targets][targetName][:UUID]
  end

  def getProductUUID targetName
    @uuidRef[:targets][targetName][:product]
  end

  def getProductUUIDArray
    uuidArray =[]

    @uuidRef[:targets].values.each do |target|
      uuidArray.push target[:product]
    end
    uuidArray
  end

  def getTargetConfigListUUID targetName
    @uuidRef[:targets][targetName][:configList]
  end

  def getTargetConfigUUID targetName, configName
    @uuidRef[:targets][targetName]["configs"][configName]
  end

  def getTargetConfigUUIDArray targetName
    @uuidRef[:targets][targetName]["configs"].values
  end

  def pushObject uuid, object
    @newProjHash["objects"][uuid] = object
  end

  def initProjHash
    @newProjHash = {"objectVersion" => @hardCoded[:objectVersion],
                    "archiveVersion" => @hardCoded[:archiveVersion],
                    "classes" => {},
                    "objects" => {},
    }
  end


  def initMainGroupObject
    @newProjHash["objects"][getRootUUID(:mainGroup)] = @objectGenerator.genGroupObject "", [getRootUUID(:productRefGroup)], "<group>"
  end

  def initRootObject
    @newProjHash["objects"][@uuidRef[:rootObject]] = {
        "buildConfigurationList" => @uuidRef[:buildConfigurationList],
        "targets" => [],
        "developmentRegion" => @hardCoded[:developmentRegion],
        "knownRegions" => @hardCoded[:knownRegions],
        "isa" => "PBXProject",
        "compatibilityVersion" => @hardCoded[:compatibilityVersion],
        "productRefGroup" => @uuidRef[:productRefGroup],
        "projectDirPath" => @hardCoded[:projectDirPath],
        "attributes" => {
            "ORGANIZATIONNAME" => @projVariable[:ORGANIZATIONNAME],
            "LastUpgradeCheck" => @hardCoded[:LastUpgradeCheck]
        },
        "hasScannedForEncodings" => @hardCoded[:hasScannedForEncodings],
        "projectRoot" => @hardCoded[:projectRoot],
        "mainGroup" => @uuidRef[:mainGroup]
    }

    @newProjHash["rootObject"] = @uuidRef[:rootObject]

  end

  def initProductGroupObject
    @newProjHash["objects"][@uuidRef[:productRefGroup]] = @objectGenerator.genGroupObject "Products", getProductUUIDArray, "<group>"
  end


  def initGlobalConfigVar
    @projVariable[:globalConfig] = {}
    @projVariable[:globalConfig][@projVariable[:configNames][0]] = {
        "ALWAYS_SEARCH_USER_PATHS" => "NO",
        "ARCHS" => "$(ARCHS_STANDARD_64_BIT)",
        "COPY_PHASE_STRIP" => "NO",
        "GCC_C_LANGUAGE_STANDARD" => "gnu99",
        "GCC_DYNAMIC_NO_PIC" => "NO",
        "GCC_ENABLE_OBJC_EXCEPTIONS" => "YES",
        "GCC_OPTIMIZATION_LEVEL" => "0",
        "GCC_PREPROCESSOR_DEFINITIONS" => ["DEBUG=1", "$(inherited)"],
        "GCC_SYMBOLS_PRIVATE_EXTERN" => "NO",
        'GCC_VERSION' => "com.apple.compilers.llvm.clang.1_0",
        "GCC_WARN_64_TO_32_BIT_CONVERSION" => "YES",
        "GCC_WARN_ABOUT_RETURN_TYPE" => "YES",
        "GCC_WARN_UNINITIALIZED_AUTOS" => "YES",
        "GCC_WARN_UNUSED_VARIABLE" => "YES",
        "MACOSX_DEPLOYMENT_TARGET" => "10.7",
        "ONLY_ACTIVE_ARCH" => "YES",
        "SDKROOT" => "macosx"
    }
  end

  def initTargetsVar

    @projVariable[:targetsName] = ["targetName"]

    @projVariable[:targets] = {}


    ####TARGET 0
    @projVariable[:targets][@projVariable[:targetsName][0]] = {}
    @projVariable[:targets][@projVariable[:targetsName][0]]["target"] = {
        "type" => "application-cli",
    }

    targetConfigs = @projVariable[:targets][@projVariable[:targetsName][0]]["targetConfigs"] = {}
    #config 0 for target 0
    targetConfigs[@projVariable[:configNames][0]] = {
        "PRODUCT_NAME" => "$(TARGET_NAME)"
    }


    }



    ######TARGET 1
    #....
  end

  def initTargets
    @projVariable[:targetsName].each do |targetName|

      @projVariable[:configNames].each do |configName|
        configSetting = @projVariable[:targets][targetName]["targetConfigs"][configName]
        configObject = @objectGenerator.genConfigObject configName, configSetting.nil? ? {} : configSetting
        configObjectUUID = getTargetConfigUUID targetName, configName


        pushObject configObjectUUID, configObject
      end


      productType = @projVariable[:targets][targetName]["target"]["type"]

      productUUID = getProductUUID targetName
      product = @objectGenerator.genOutputFile productType, targetName
      pushObject productUUID, product


      configList = @objectGenerator.genConfigurationList @hardCoded[:defaultConfigurationIsVisible], @projVariable[:configNames][0], getTargetConfigUUIDArray(targetName)
      configListUUID = getTargetConfigListUUID targetName
      pushObject configListUUID, configList

      targetUUID =  getTargetUUID targetName
      targetObject = @objectGenerator.genTargetObject targetName, configListUUID, productUUID, productType, []
      pushObject targetUUID, targetObject


      @newProjHash["objects"][getRootUUID(:rootObject)]["targets"].push getTargetUUID targetName
    end
end


  def generateGlobalConfigObject
    @projVariable[:configNames].each do |name|
      @newProjHash["objects"][getGlobalConfigUUID(name)] =
          @objectGenerator.genConfigObject name, @projVariable[:globalConfig][name]
    end
  end

  def initGlobalConfigurationListObject
    generateGlobalConfigObject
    @newProjHash["objects"][getRootUUID(:buildConfigurationList)] =
        @objectGenerator.genConfigurationList @hardCoded[:defaultConfigurationIsVisible],
                                              @projVariable[:configNames][0],
                                              getGlobalConfigUUIDArray

  end



  def save path
    @jsonConverter.save_pbxproj path, @newProjHash
  end

end