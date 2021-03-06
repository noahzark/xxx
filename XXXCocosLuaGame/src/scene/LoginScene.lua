--------------------------------
-- LoginScene.lua - 游戏登录场景
-- @author fangzhou.long
-- TODO Add login panel
--------------------------------

require("core.BaseScene")
require("config.CommonDefine")


local LoginScene = class("LoginScene", function() return BaseScene.create() end)

function LoginScene:ctor()
    self.sceneName = "LoginScene"
end

--------------------------------------------------------------------------------
-- Scene initialize progress:
-- BaseScene.create -> BaseScene.new -> BaseScene.ctor -> LoginScene.ctor -> 
-- BaseScene.initScene -> LoginScene.onInit()
--------------------------------------------------------------------------------
function LoginScene.create()
    local scene = LoginScene.new()
    scene:initScene()
    return scene
end

function LoginScene:initGame(sceneName)
    DataManager.loadUserInfo()
    MetaManager.init()
    ParticleManager.init()
    AnimationManager.init()
    SoundManager.init()
    NetworkManager.init()
    
    local function doInit()
        local request = InitRequest.create()
        request.postRequest = function()
            SceneManager.replaceSceneWithName(sceneName)
        end
        NetworkManager.send(request)
    end
    
    local function doLogin()
        local request = LoginRequest.create()
        request.postRequest = doInit
        NetworkManager.send(request)
    end
    
    cclog("Path: " .. cc.UserDefault:getXMLFilePath())
    local inst = cc.UserDefault:getInstance()
    local uuid = inst:getStringForKey("uuid")
    if uuid and uuid~="" then
        cclog("UUID: " .. uuid)
        doLogin()
    else
        local request = RegisterRequest.create()
        request.postRequest = doLogin
        NetworkManager.send(request)
    end
    
    SoundManager.playBGM('menu', true)
end

function LoginScene:onInit()
    self:addChild(self:createBackLayer())
    self:addChild(self:createBtnLayer())
    
   --DataManager.loadUserInfo()
    --local bgMusicPath = cc.FileUtils:getInstance():fullPathForFilename("sound/bgm_game.wav")
    --AudioEngine.playMusic(bgMusicPath, true)
    --SoundManager.playBGM('menu', true)
end

function LoginScene:onEnter()
    local action = cc.FadeIn:create(2.0)
    self.logoSprite:runAction(action)
end

function LoginScene.createTextBtn(btnStr)
	local button = ccui.Button:create()
    button:setTitleText(btnStr)
	button:setScale(4)
	
	local scale1 = cc.ScaleTo:create(1.5, 3.5)
	local scale2 = cc.ScaleTo:create(2, 4)

    local arrayOfActions = {scale1,scale2}

	local sequence = cc.Sequence:create(arrayOfActions)

	local repeatFunc = cc.RepeatForever:create(sequence)
    button:runAction(repeatFunc)

    return button
end

function LoginScene:createBackLayer()
	local backLayer = cc.Layer:create()

    local bgSprite = cc.Sprite:create("imgs/main_menu_bg.png")
    bgSprite:setPosition(self.visibleSize.width / 2, self.visibleSize.height / 2)
    backLayer:addChild(bgSprite)
    
    self.logoSprite = cc.Sprite:create("imgs/main_menu_logo.png")
    self.logoSprite:setPosition(self.visibleSize.width / 2, self.visibleSize.height / 3)
    backLayer:addChild(self.logoSprite)
    self.logoSprite:setOpacity(0)

	return backLayer
end

function LoginScene:createBtnLayer()
    local btnLayer = cc.Layer:create()
    
    -- handing touch events
    local touchBeginPoint = nil

    local function onTouchEnded()
        self:initGame("MainMenuScene")

        -- CCTOUCHBEGAN event must return true
        return true
    end

    local function onStartBtnPress(sender, eventType)
        if not self.touchEnabled then return true end
        if eventType == ccui.TouchEventType.ended then   
            self.touchEnabled = false
            return onTouchEnded()
        end
    end

    local startBtn = self.createTextBtn("Press Here to Start")

    startBtn:addTouchEventListener(onStartBtnPress)
    startBtn:setPosition(cc.p(self.visibleSize.width / 2, self.visibleSize.height * 0.32))
    btnLayer:addChild(startBtn)

    local function onDebugBtnPress(sender, eventType)
        if not self.touchEnabled then return true end
        if eventType == ccui.TouchEventType.ended then
            self:initGame("TestScene")
            return true
        end
    end

    local debugBtn = self.createTextBtn("Debug Particular Scene");
    debugBtn:addTouchEventListener(onDebugBtnPress)
    debugBtn:setPosition(cc.p(self.visibleSize.width / 2, self.visibleSize.height * 0.22))
    --btnLayer:addChild(debugBtn)
    
    return btnLayer
end

return LoginScene