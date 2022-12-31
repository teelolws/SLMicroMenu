if not (GetBuildInfo() == "10.0.2") then return end -- force update every patch incase of UI changes that cause problems and/or make this addon redundant!

local db

local incompatibleAddons = {
    "Bartender4",
    "Dominos",
    }

local defaults = {
    global = {
        EMEOptions = {
            menu = true,
        },
        MicroButtonAndBagsBar = {},
    }
}

local options = {
    type = "group",
    set = function(info, value) db.global.EMEOptions[info[#info]] = value end,
    get = function(info) return db.global.EMEOptions[info[#info]] end,
    args = {
        menu = {
            name = "Menu Bar",
            desc = "Enables / Disables Edit Mode support for the Menu Bar. Disable if you are having compatibility issues with another addon.",
            type = "toggle",
        },
    }
}

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("UNIT_PORTRAIT_UPDATE");
f:RegisterEvent("PORTRAITS_UPDATED");
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, arg1)
    if (event == "ADDON_LOADED") and (arg1 == "SLMicroMenu") then
        db = LibStub("AceDB-3.0"):New("SLMicroMenuADB", defaults)
        
        --
        -- Start legacy db import - remove this eventually
        --
        local legacydb = LibStub("AceDB-3.0"):New("SLMicroMenuDB", defaults)
        legacydb = legacydb.global
        for buttonName, buttonData in pairs(legacydb) do
            local isEmpty = true
            if db.global[buttonName] and (type(db.global[buttonName]) == "table") then
                for k, v in pairs(db.global[buttonName]) do
                    isEmpty = false
                    break
                end
            end
            if isEmpty then
                db.global[buttonName] = buttonData
                legacydb[buttonName] = nil
            end
        end
        --
        -- End legacy db import
        --

        -- moving/resizing found to be incompatible
        for _, addon in pairs(incompatibleAddons) do
            if IsAddOnLoaded(addon) then return end
        end
        
        AceConfigRegistry:RegisterOptionsTable("SLMicroMenu", options)
        AceConfigDialog:AddToBlizOptions("SLMicroMenu")
        
        if not db.global.EMEOptions.menu then return end 
        
        lib:RegisterFrame(MicroButtonAndBagsBar, "Menu Bar", db.global.MicroButtonAndBagsBar)
        lib:RegisterResizable(MicroButtonAndBagsBarMovable)
        lib:RegisterResizable(EditModeExpandedBackpackBar)
        lib:RegisterHideable(MicroButtonAndBagsBarMovable)
        lib:RegisterHideable(EditModeExpandedBackpackBar)
        
        hooksecurefunc("MoveMicroButtons", function()
            CharacterMicroButton:ClearAllPoints()
            CharacterMicroButton:SetPoint("BOTTOMLEFT", MicroButtonAndBagsBarMovable, "BOTTOMLEFT", 7, 6)
            LFDMicroButton:ClearAllPoints()
            LFDMicroButton:SetPoint("BOTTOMLEFT", GuildMicroButton, "BOTTOMRIGHT", 1, 0)
        end)
    end
end)

local prefix = "hud-microbutton-";
	
local function replaceAtlases(self, name)
    -- code from 9.2 version of FrameXML\MainMenuBarMicroButtons.lua
    self:SetNormalAtlas(prefix..name.."-Up", true);
	self:SetPushedAtlas(prefix..name.."-Down", true);
	self:SetDisabledAtlas(prefix..name.."-Disabled", true);
	self:SetHighlightAtlas("hud-microbutton-highlight");
end

local buttons = {
    {button = CharacterMicroButton, name = "Character"},
    {button = SpellbookMicroButton, name = "Spellbook"},
    {button = TalentMicroButton, name = "Talents"},
    {button = AchievementMicroButton, name = "Achievement"},
    {button = QuestLogMicroButton, name = "Quest"},
    {button = GuildMicroButton, name = "Socials"},
    {button = LFDMicroButton, name = "LFG"},
    {button = CollectionsMicroButton, name = "Mounts"},
    {button = EJMicroButton, name = "EJ"},
    {button = StoreMicroButton, name = "BStore"},  
    {button = MainMenuMicroButton, name = "MainMenu"},
}

local texture = CharacterMicroButton:CreateTexture("MicroButtonPortrait", "OVERLAY")
texture:SetPoint("TOP", 0, -6)
texture:SetSize(10, 16)
texture:SetTexCoord(0.2, 0.8, 0.0666, 0.9)

local function replaceAllAtlases()
    for _, data in pairs(buttons) do
        replaceAtlases(data.button, data.name)
    end
    SetPortraitTexture(MicroButtonPortrait, "player")
end
replaceAllAtlases()

f:HookScript("OnEvent", function()
    replaceAllAtlases()
end)

CharacterMicroButton:HookScript("OnEvent", function()
    SetPortraitTexture(MicroButtonPortrait, "player")
end)

local function CharacterMicroButton_SetPushed()
    SetPortraitTexture(MicroButtonPortrait, "player")
	MicroButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333);
	MicroButtonPortrait:SetAlpha(0.5);
	CharacterMicroButton:SetButtonState("PUSHED", true);
end
local function CharacterMicroButton_SetNormal()
    SetPortraitTexture(MicroButtonPortrait, "player")
	MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9);
	MicroButtonPortrait:SetAlpha(1.0);
	CharacterMicroButton:SetButtonState("NORMAL");
end

CharacterMicroButton:HookScript("OnMouseDown", function(self)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		if ( self.down ) then
            CharacterMicroButton_SetPushed();
		else
			
		end
	end
end)
CharacterMicroButton:HookScript("OnMouseUp", function(self, button)
	if ( KeybindFrames_InQuickKeybindMode() ) then
	else
		if ( self.down ) then
		elseif ( self:GetButtonState() == "NORMAL" ) then
			CharacterMicroButton_SetNormal();
		else
			CharacterMicroButton_SetPushed();
		end
	end
end)

MainMenuMicroButton:CreateTexture("MainMenuBarDownload", "OVERLAY")
MainMenuBarDownload:SetPoint("BOTTOM", "MainMenuMicroButton", "BOTTOM", 0, 7)
MainMenuBarDownload:SetSize(28, 28)

MainMenuMicroButton:HookScript("OnUpdate", function(self, elapsed)
    local status = GetFileStreamingStatus();
        if ( status == 0 ) then
    	MainMenuBarDownload:Hide();
    	self:SetNormalAtlas("hud-microbutton-MainMenu-Up", true);
    	self:SetPushedAtlas("hud-microbutton-MainMenu-Down", true);
    	self:SetDisabledAtlas("hud-microbutton-MainMenu-Disabled", true);
    else
    	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Up");
    	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Down");
    	self:SetDisabledTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Up");
    	if ( status == 1 ) then
    		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Green");
    	elseif ( status == 2 ) then
    		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Yellow");
    	elseif ( status == 3 ) then
    		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Red");
    	end
    	MainMenuBarDownload:Show();
    end
    self:SetHighlightAtlas("hud-microbutton-highlight")
end)

CreateFrame("Frame", "GuildMicroButtonTabard", GuildMicroButton)
GuildMicroButtonTabard:SetPoint("TOPLEFT", 3, 1)
GuildMicroButtonTabard:SetPoint("BOTTOMRIGHT", -3, -1)

GuildMicroButtonTabard.background = GuildMicroButtonTabard:CreateTexture("GuildMicroButtonTabardBackground", "ARTWORK")
GuildMicroButtonTabardBackground:SetAtlas("hud-microbutton-Guild-Banner", true)
GuildMicroButtonTabardBackground:SetPoint("CENTER", 0, 0)

GuildMicroButtonTabard.emblem = GuildMicroButtonTabard:CreateTexture("GuildMicroButtonTabardEmblem", "OVERLAY")
GuildMicroButtonTabardEmblem:SetMask("Interface\GuildFrame\GuildEmblems_01")
GuildMicroButtonTabardEmblem:SetSize(14, 14)
GuildMicroButtonTabardEmblem:SetPoint("CENTER", 0, 0)

local function GuildMicroButton_UpdateTabard()
    local self = GuildMicroButton
	local tabard = GuildMicroButtonTabard;

	-- switch textures if the guild has a custom tabard
	local emblemFilename = select(10, GetGuildLogoInfo());
	if ( emblemFilename ) then
		if ( not tabard:IsShown() ) then
            local button = GuildMicroButton;
			button:SetNormalAtlas("hud-microbutton-Character-Up", true);
			button:SetPushedAtlas("hud-microbutton-Character-Down", true);
			-- no need to change disabled texture, should always be available if you're in a guild
			tabard:Show();
		end
        SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background);
	else
		if ( tabard:IsShown() ) then
			local button = GuildMicroButton;
			button:SetNormalAtlas("hud-microbutton-Socials-Up", true);
			button:SetPushedAtlas("hud-microbutton-Socials-Down", true);
			button:SetDisabledAtlas("hud-microbutton-Socials-Disabled", true);
			tabard:Hide();
		end
	end
	tabard.needsUpdate = nil;
end
GuildMicroButton_UpdateTabard()
C_Timer.After(4, GuildMicroButton_UpdateTabard)

hooksecurefunc("UpdateMicroButtons", function()
    if ( CharacterFrame and CharacterFrame:IsShown() ) then
		CharacterMicroButton_SetPushed();
	else
		CharacterMicroButton_SetNormal();
	end
    GuildMicroButton_UpdateTabard()
    if ( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( GuildFrame and GuildFrame:IsShown() ) then
		GuildMicroButtonTabard:SetPoint("TOPLEFT", 2, 0);
		GuildMicroButtonTabard:SetAlpha(0.70);
	else
		GuildMicroButtonTabard:SetPoint("TOPLEFT", 3, 1);
		GuildMicroButtonTabard:SetAlpha(1);
    end
end)